using module .\FileUtils.psm1
using module .\HtmlParser.psm1
using module .\Minifier.psm1
using module .\MdParser.psm1


class MarkdownToHtml {
    [string]$DocDir
    [string]$DstDir
    [string]$TmpDir

    MarkdownToHtml([string]$docDir, [string]$dstDir, [string]$tmpDir) {
        $this.DocDir = $docDir
        $this.DstDir = $dstDir
        $this.TmpDir = $tmpDir
    }

    #---------------------------------------------------------------------------

    [void] Convert() {
        # Obtém todos os arquivos Markdown da pasta temporária
        $markdownFiles = Get-ChildItem -Path $this.TmpDir -Filter "*.md" -Recurse -Exclude "\templates\*"
        # Converte os arquivos Markdown em HTML
        $totalFiles = $markdownFiles.Count
        $currentFileIndex = 0
        foreach ($md in $markdownFiles) {
            $currentFileIndex++
            $percentComplete = ($currentFileIndex / $totalFiles) * 100
            $pct = [math]::Round($percentComplete)
            Write-Progress -Activity "$currentFileIndex / $totalFiles ($pct%)" ` -Status "Convertendo '$($md.Name)' ..." -PercentComplete $percentComplete
            #
            $mdContent = Get-Content -Path $md.FullName -Raw
            # Processa diretivas de inclusão
            $mdContent = [MdParser]::Parser($this.TmpDir, $mdContent)
            #
            Set-Content -Path $md.FullName -Value $mdContent
            # Converte para HTML
            $this.ToHtml( $md.FullName )
        }
    }

    #---------------------------------------------------------------------------

    [void] Minificar([string]$fullHtmlFile) {
        <#
        Minifica o arquivo HTML.

        Args:
            fullHtmlFile (string): Caminho completo para o arquivo HTML.
        #>

        $minifier = [Minifier]::new()
        # $minifiedFile = $fullHtmlFile -replace '\.html$', '.min.html'
        $minifiedFile = $fullHtmlFile
        $minifier.MinifyHTML($fullHtmlFile, $minifiedFile)
    }

    #---------------------------------------------------------------------------

    [void] ToHtml( [string]$fullFilePath ) {
        <#
        Converte um arquivo Markdown em HTML usando Pandoc e ajusta o conteúdo HTML.

        Args:
            fullFilePath (string): Caminho completo para o Markdown.
        #>

        $relatPath = [FileUtils]::GetRelativePath($fullFilePath, $this.DocDir)
        $htmlFullFilePath = Join-Path -Path $this.DstDir -ChildPath ($relatPath -replace '\.md$', '.html') # Substitui .md por .html

        $destDir = Split-Path -Path $htmlFullFilePath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory | Out-Null
        }

        $pandocExe = Join-Path -Path $global:scriptDir -ChildPath "apps/pandoc.exe"
        # Construir o comando pandoc
        $pandocCmd = "& `"$pandocExe`" `"$fullFilePath`" -o `"$htmlFullFilePath`" --template `"templates/main.template.html`" --standalone --wrap=none --from markdown+raw_html"
        # Imprimir o comando antes de sua execução
        Write-Host "`nExecutando: $pandocCmd"
        # Executar o comando pandoc
        Invoke-Expression $pandocCmd

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Erro ao converter $fullFilePath pandoc retornou código $LASTEXITCODE"
            Read-Host "--- ERRO --- Pressione Enter para continuar --- ERRO ---"
            return
        }

        # Lê o conteúdo do arquivo HTML gerado
        $htmlContent = Get-Content -Path $htmlFullFilePath -Raw
        $htmlContent = [HtmlParser]::Parser($htmlContent, $relatPath)
        # Atualiza o arquivo HTML no disco
        Set-Content -Path $htmlFullFilePath -Value $htmlContent
        Write-Host "Convertido: $fullFilePath -> $htmlFullFilePath"
    }

} # end-class MarkdownToHtml