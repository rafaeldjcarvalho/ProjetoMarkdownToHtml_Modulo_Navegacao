using module .\MdRegEx.psm1


class FileUtils {

    static [string] GetRelativePath([string]$fullFileName, [string]$BaseDir) {
        return (Resolve-Path $fullFileName).Path.Substring((Resolve-Path $BaseDir).Path.Length).TrimStart('\','/')
    }

    static [bool] IsEmptyDir([string]$Dir) {
        <#
        Verifica se o diretório está vazio.
    
        Args:
            Dir (string): Diretório a ser verificado.
    
        Returns:
            bool: Retorna $true se o diretório estiver vazio, caso contrário, $false.
        #>    
        $files = Get-ChildItem -Path $Dir -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        return -not $files
    }

    static [void] CopyDocToTmp([string]$DocDir, [string]$DstDir) {
        <#
        Copia todos os arquivos .md do diretório de origem para o de destino,
        ignorando as pastas '$DocDir\assets' e '$DocDir\templates', de forma eficiente.
        #>

        Write-Host "`nCopiando arquivos de '$DocDir' para '$DstDir', excluindo '$DocDir\assets' ..."

        # Comando robocopy
        $robocopyCmd = "robocopy `"$DocDir`" `"$DstDir`" *.md /E /XD `"$DocDir\assets`" /NFL /NDL /NJH /NJS /NC /NS /NP"
        # Exibe o comando no terminal
        Write-Host "Executando comando: $robocopyCmd"
        # Executa o comando
        Invoke-Expression $robocopyCmd
    }

    static [void] CopyAssets([string]$DocDir, [string]$DstDir) {
        <#
        Copia a pasta 'assets' para a pasta de destino.
        #>

        Write-Host "`nCopiando assets para a pasta de destino...`n"

        $docAssets = Join-Path -Path $DocDir -ChildPath "assets"
        $pandocAssets = Join-Path -Path $global:scriptDir -ChildPath "assets/__dist"  # distribution assets

        $dstDocAssets = Join-Path -Path $DstDir -ChildPath "assets"
        $dstPandocAssets = Join-Path -Path $DstDir -ChildPath "assets/assets-do-script"

        # Cria a pasta de destino se ela não existir
        New-Item -Path $dstDocAssets -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $dstPandocAssets -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

        $robocopyCmdSrc = "robocopy `"$docAssets`" `"$dstDocAssets`" /E /NFL /NDL /NJH /NJS /NC /NS /NP"
        Invoke-Expression $robocopyCmdSrc
        $robocopyCmdPandoc = "robocopy `"$pandocAssets`" `"$dstPandocAssets`" /E /NFL /NDL /NJH /NJS /NC /NS /NP"
        Invoke-Expression $robocopyCmdPandoc
    }

    static [void] ClearFolders([string]$TmpDir, [string]$DstDir, [string]$tmpExpectedFile, [string]$distExpectedFile) {
        <#
        Limpa as pastas temporária e de destino, verificando se estão corretas antes da exclusão.

        Args:
            TmpDir (string): Pasta temporária que será limpa.
            DstDir (string): Pasta de destino que será limpa.

        Descrição:
            Esta função verifica se as pastas temporária e de destino estão corretas antes de excluí-las.
            Ela cria as pastas se elas não existirem, verifica se há arquivos não-MD nas pastas,
            e remove todos os arquivos dentro das pastas se as verificações passarem.
        #>

        # Limpa a pasta temporária
        [FileUtils]::ClearTmpFolder($TmpDir, $tmpExpectedFile)
        # Limpa a pasta de destino
        [FileUtils]::ClearDstFolder($DstDir, $distExpectedFile)
    }  


    static [void] ClearTmpFolder([string]$TmpDir, [string]$expectedFile) {
        <#
        Limpa a pasta temporária, verificando se está correta antes da exclusão.
    
        Args:
            TmpDir (string): Pasta temporária que será limpa.
            expectedFile (string): Nome do arquivo que indica que a pasta temporária está correta.
                expected-file-55105b98-f704-40a0-8171-25e5255daf61.tmp
    
        Descrição:
            Esta função verifica se a pasta temporária está correta antes de excluí-la.
            Ela cria a pasta se ela não existir, verifica se há arquivos não-MD na pasta temporária,
            e remove todos os arquivos dentro da pasta temporária se as verificações passarem.
        #>
        [FileUtils]::CreateDir($TmpDir)
    
        if ([FileUtils]::IsEmptyDir($TmpDir)) {
            return
        }

        # Verifica se a pasta contém um arquivo específico que indica que é a pasta correta
        if (-not (Test-Path -Path "$TmpDir/$expectedFile")) {
            Write-Error "Exclusão da pasta temporária abortada ('$TmpDir') ! `nNão parece ser a pasta correta. Faça a exclusão manual por segurança."
            exit 1
        }
    
        # Limpa a pasta temporária
        Remove-Item -Path "$TmpDir\*" -Recurse -Force
    
        Write-Host "`nClearTmpFolder. Executado com sucesso. Excluídos os arquivos:"
        Write-Host "tmpDir: $TmpDir"
    }
    
    static [void] ClearDstFolder([string]$DstDir, [string]$expectedFile) {
        <#
        Limpa a pasta de destino, verificando se está correta antes da exclusão.
    
        Args:
            DstDir (string): Pasta de destino que será limpa.
            expectedFile (string): Nome do arquivo que indica que a pasta de destino está correta.
                expected-file-8e350305-676e-44b4-a5da-def053fcd269.tmp
    
        Descrição:
            Esta função verifica se a pasta de destino está correta antes de excluí-la.
            Ela cria a pasta se ela não existir, verifica se há arquivos não-MD na pasta de destino,
            e remove todos os arquivos dentro da pasta de destino se as verificações passarem.
        #>    
        [FileUtils]::CreateDir($DstDir)

        if ([FileUtils]::IsEmptyDir($DstDir)) {
            return
        }
    
        # Verifica se a pasta contém um arquivo específico que indica que é a pasta correta
        if (-not (Test-Path -Path "$DstDir/$expectedFile")) {
            Write-Error "Exclusão da pasta de destino abortada ('$DstDir') ! `nNão parece ser a pasta correta. Faça a exclusão manual por segurança."
            exit 1
        }
    
        # Limpa a pasta de destino
        Remove-Item -Path "$DstDir\*" -Recurse -Force
    
        Write-Host "`nClearDstFolder. Executado com sucesso. Excluídos os arquivos:"
        Write-Host "dstDir: $DstDir"
    }


    static [void] TestAssetsExists([string]$DstDir) {
        <#
        Verifica se os assets referenciados nos arquivos HTML existem no diretório de destino.

        Args:
            DstDir (string): Diretório de destino.
        #>

        $htmlFiles = Get-ChildItem -Path $DstDir -Filter "*.html" -Recurse
        foreach ($html in $htmlFiles) {
            $htmlContent = Get-Content -Path $html -Raw
            # Check se os assets existem
            # 1. Obtém relatFileName de todos os assets
            $matchesLst = [MdRegEx]::UpdateAssetsSource.Matches($htmlContent)
            foreach ($m in $matchesLst) {
                $path = $m.Groups[2].Value
                $assetPath = Join-Path -Path $DstDir -ChildPath $path
                # 2. Testa se o asset existe
                if (-not (Test-Path $assetPath)) {
                    $htmlRelPath = [FileUtils]::GetRelativePath($html.FullName, $DstDir)
                    $global:warningsList += "TestAssetsExists. '$htmlRelPath', Asset não encontrado: '$assetPath'"
                }
            }
        }
    }

    static [string[]] GetFiles([string]$dir, [string]$filter) {
        return Get-ChildItem -Path $dir -Filter $filter -Recurse | Select-Object -ExpandProperty FullName
    }

    static [void] CreateDir([string]$dir) {
        New-Item -Path $dir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    }

    static [void] RenameFilesExt([string[]]$files, [string]$newExtension) {
        foreach ($f in $files) {
            $newFileName = [System.IO.Path]::ChangeExtension($f, $newExtension)
            Rename-Item -Path $f -NewName $newFileName -ErrorAction SilentlyContinue
        }
    }
} # end-class FileUtils
