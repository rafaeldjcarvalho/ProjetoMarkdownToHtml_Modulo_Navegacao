using module .\FileUtils.psm1


class Minifier {
    <#
    .SYNOPSIS
        Classe para minificar arquivos HTML, CSS e JS.

    .DESCRIPTION
        Esta classe fornece métodos para minificar arquivos HTML, CSS e JavaScript, reduzindo seu tamanho
        através da remoção de espaços em branco, comentários e outros elementos desnecessários.

    .NOTES
        Os minificadores devem estar disponíveis no PATH do sistema ou instalados localmente (node_modules/.bin).
        Requer: npm install --save-dev html-minifier terser cssnano postcss postcss-cli
    #>

    hidden [string] $htmlMinifier = "html-minifier"
    hidden [string] $cssMinifier = "postcss" # Usando postcss para executar o cssnano
    hidden [string] $jsMinifier = "terser"

    # Atributos para controle da barra de progresso
    hidden [int]$TotalFiles
    hidden [int]$ProcessedFiles
    hidden [string]$Activity


    [void] HTML([string]$inputFile, [string]$outputFile) {
        <#
        .SYNOPSIS
            Minifica um arquivo HTML.

        .DESCRIPTION
            Este método utiliza o html-minifier para minificar o arquivo HTML especificado.

        .PARAMETER inputFile
            O caminho para o arquivo HTML de entrada.

        .PARAMETER outputFile
            O caminho para o arquivo HTML de saída minificado.

        .EXAMPLE
            $minifier = New-Object Minifier
            $minifier.HTML("index.html", "index.min.html")
        #>
        $this.Execute($this.htmlMinifier, $inputFile, $outputFile, @(
            "--collapse-whitespace", "--remove-comments", "--remove-optional-tags",
            "--remove-redundant-attributes", "--remove-script-type-attributes",
            "--remove-tag-whitespace", "--use-short-doctype", "--minify-css", "true",
            "--minify-js", "true"
        ))
    }

    [void] CSS([string]$inputFile, [string]$outputFile) {
        <#
        .SYNOPSIS
            Minifica um arquivo CSS ou SCSS.
    
        .DESCRIPTION
            Este método utiliza o sass para compilar SCSS para CSS e o cssnano (via postcss) para minificar o arquivo CSS especificado com compressão máxima.
            Cria um arquivo de configuração 'postcss.config.js' se ele não existir.
    
        .PARAMETER inputFile
            O caminho para o arquivo CSS ou SCSS de entrada.
    
        .PARAMETER outputFile
            O caminho para o arquivo CSS de saída minificado.
    
        .EXAMPLE
            $minifier = New-Object Minifier
            $minifier.CSS("style.scss", "style.min.css")
        #>
        # Verifica se o arquivo de configuração do postcss existe
        $configPath = Join-Path -Path $global:scriptDir -ChildPath "postcss.config.js"
        if (!(Test-Path $configPath)) {
            # Cria um arquivo de configuração básico para o cssnano com compressão máxima
            "module.exports = { plugins: [ require('cssnano')({ preset: 'advanced' }) ] }" | Out-File -Encoding utf8 $configPath
            Write-Host "Arquivo de configuração 'postcss.config.js' criado para o cssnano."
        }
    
        # Verifica se o arquivo de entrada é SCSS
        $tempCssFile = $null
        if ($inputFile -like "*.scss") {
            $tempCssFile = [System.IO.Path]::ChangeExtension($inputFile, ".css")
            sass $inputFile $tempCssFile
            $inputFile = $tempCssFile
        }
    
        $this.Execute($this.cssMinifier, $inputFile, $outputFile, @(
            "--use", "cssnano"
        ))
    
        # Remove o arquivo CSS temporário se foi gerado a partir de SCSS
        if ($tempCssFile) {
            Remove-Item $tempCssFile
        }
    }

    [void] JavaScript([string]$inputFile, [string]$outputFile) {
        <#
        .SYNOPSIS
            Minifica um arquivo JavaScript.

        .DESCRIPTION
            Este método utiliza o terser para minificar o arquivo JavaScript especificado com compressão máxima e suporte a ES2022.

        .PARAMETER inputFile
            O caminho para o arquivo JavaScript de entrada.

        .PARAMETER outputFile
            O caminho para o arquivo JavaScript de saída minificado.

        .EXAMPLE
            $minifier = New-Object Minifier
            $minifier.JavaScript("script.js", "script.min.js")
        #>
        $this.Execute($this.jsMinifier, $inputFile, $outputFile, @(
            "--compress", "passes=3,pure_getters",
            "--mangle", "toplevel",
            "--ecma", "2022"
        ))
    }

    [string[]] All([string]$inputDir, [string]$outputDir, [string]$extension) {
        <#
        .SYNOPSIS
            Minifica todos os arquivos de um determinado tipo em um diretório.

        .DESCRIPTION
            Este método itera por todos os arquivos com a extensão especificada dentro do diretório de entrada
            e os minifica, salvando-os no diretório de saída. Ignora arquivos já minificados (com extensão .min.$extension).

        .PARAMETER inputDir
            O caminho para o diretório de entrada.

        .PARAMETER outputDir
            O caminho para o diretório de saída.

        .PARAMETER extension
            A extensão dos arquivos a serem minificados (ex: "html", "css", "js").

        .EXAMPLE
            $minifier = New-Object Minifier
            $minifier.All("src", "dist", "html")
            $minifier.All("src", "dist", "css")
            $minifier.All("src", "dist", "js")
        #>
        [FileUtils]::CreateDir($outputDir)
        $files = [FileUtils]::GetFiles($inputDir, "*.$extension")
        $outFiles = @()
        $filesOfCurrentExtension = $files.Count # Variável local para armazenar o número de arquivos da extensão atual
        $currentFileIndex = 0

        foreach ($file in $files) {
            $currentFileIndex++
            $file = [System.IO.FileInfo]$file
            # Verifica se o arquivo já está minificado
            if ($file.BaseName.EndsWith(".min")) {
                Write-Host "Ignorando arquivo já minificado: $($file.FullName)"
                continue
            }

            # Obtém o caminho relativo do arquivo em relação ao diretório de entrada
            $relativePath = $file.FullName.Substring($inputDir.Length)
            # Constrói o caminho de saída combinando o diretório de saída com o caminho relativo
            $outputFile = Join-Path -Path $outputDir -ChildPath $relativePath
            #
            $outputSubDir = Split-Path -Path $outputFile -Parent
            [FileUtils]::CreateDir($outputSubDir)

            # Atualiza a barra de progresso geral
            $this.ProcessedFiles++
            $percentComplete = [int]($this.ProcessedFiles / $this.TotalFiles * 100)
            # Usa $filesOfCurrentExtension para exibir a contagem correta no status da barra de progresso
            Write-Progress -Activity $this.Activity -Status "'$($file.Name)' ($currentFileIndex/$filesOfCurrentExtension)" -PercentComplete $percentComplete -Id 0

            switch ($extension) {
                "html" { $this.HTML($file.FullName, $outputFile) }
                "css"  { $this.CSS($file.FullName, $outputFile) }
                "js"   { $this.JavaScript($file.FullName, $outputFile) }
            }
            $outFiles += $outputFile
        }

        return $outFiles
    }

    [PSCustomObject] AllFiles([string]$inputDir, [string]$outputDir) {
        <#
        .SYNOPSIS
            Minifica todos os arquivos HTML, CSS e JavaScript em um diretório.

        .DESCRIPTION
            Este método itera por todos os arquivos HTML, CSS e JavaScript dentro do diretório de entrada
            e os minifica, salvando-os no diretório de saída. Ignora arquivos já minificados.

        .PARAMETER inputDir
            O caminho para o diretório de entrada.

        .PARAMETER outputDir
            O caminho para o diretório de saída.

        .EXAMPLE
            $minifier = New-Object Minifier
            $minifier.AllFiles("src", "dist")
        #>
        # Coleta todos os arquivos
        $allFiles = @(
            [FileUtils]::GetFiles($inputDir, "*.html")
            [FileUtils]::GetFiles($inputDir, "*.css")
            [FileUtils]::GetFiles($inputDir, "*.js")
        )

        # Remove arquivos já minificados
        $allFiles = $allFiles | Where-Object { $_.Name -notmatch '(?i)\.min\.(html|css|js)$' }

        # Inicializa os atributos de controle da barra de progresso
        $this.TotalFiles = $allFiles.Count
        $this.ProcessedFiles = 0
        $this.Activity = "Minificando"

        # Minifica HTML
        Write-Progress -Id 0 -Activity $this.Activity -Status "HTML..." -PercentComplete 0
        $htmlFiles = $this.All($inputDir, $outputDir, "html")

        # Minifica CSS
        Write-Progress -Id 0 -Activity $this.Activity -Status "CSS..." -PercentComplete ([int]($this.ProcessedFiles / $this.TotalFiles * 100))
        $cssFiles = $this.All($inputDir, $outputDir, "css")

        # Minifica JS
        Write-Progress -Id 0 -Activity $this.Activity -Status "JavaScript..." -PercentComplete ([int]($this.ProcessedFiles / $this.TotalFiles * 100))
        $jsFiles = $this.All($inputDir, $outputDir, "js")

        # Completa a barra de progresso geral
        Write-Progress -Id 0 -Activity $this.Activity -Completed -Status "Concluído!"

        return [PSCustomObject]@{
            html = $htmlFiles;
            css  = $cssFiles;
            js   = $jsFiles;
        }
    }

    hidden [void] Execute([string]$minifierPath, [string]$inputFile, [string]$outputFile, [string[]]$baseArgs) {
        <#
        .SYNOPSIS
            Executa o minificador especificado com os argumentos fornecidos.

        .DESCRIPTION
            Este método é um método auxiliar oculto que executa o comando do minificador com os argumentos base,
            o arquivo de entrada e o arquivo de saída. Se o minificador estiver instalado localmente (node_modules/.bin),
            o método irá construir o caminho para o executável usando o caminho relativo.

        .PARAMETER minifierPath
            O nome do executável do minificador.

        .PARAMETER inputFile
            O caminho para o arquivo de entrada.

        .PARAMETER outputFile
            O caminho para o arquivo de saída.

        .PARAMETER baseArgs
            Os argumentos base para passar para o minificador.
        #>
        # Verifica se o minificador está no PATH ou instalado localmente
        if (Get-Command $minifierPath -ErrorAction SilentlyContinue) {
            $minifierCommand = $minifierPath
        } else {
            # Constrói o caminho relativo para o executável local
            $localMinifierPath = Join-Path -Path $global:scriptDir -ChildPath "node_modules/.bin/$minifierPath"
            if (Test-Path $localMinifierPath) {
                $minifierCommand = $localMinifierPath
            } else {
                Write-Error "Minificador '$minifierPath' não encontrado no PATH nem localmente (node_modules/.bin)."
                return
            }
        }

        # Monta os argumentos corretamente
        # html-minifier e terser: --output <arquivo_saida> <arquivo_entrada>
        # postcss (cssnano): --output <arquivo_saida> <arquivo_entrada>

        if ($minifierPath -in ("html-minifier", "terser", "postcss")) {
            $inputFile = "`"$inputFile`""
            $outputFile = "`"$outputFile`""
            $args = $baseArgs + @("--output", $outputFile, $inputFile)
        } else {
            Write-Error "Minificador '$minifierPath' não suportado por este método."
            return
        }

        $cmd = "$minifierCommand " + ($args -join " ")
        Write-Host "Executando: $cmd"
        Invoke-Expression $cmd
    }
}