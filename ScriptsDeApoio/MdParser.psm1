using namespace System.Text
using namespace System.Text.RegularExpressions

using module .\MdRegEx.psm1


class MdParser {
    [string]$TmpDir
    [StringBuilder]$__MdContent

    <#
    Construtor para MdParser

    Args:
        tmpDir (string): Caminho temporário/base
        mdContent (string): Conteúdo markdown original
    #>
    MdParser([string]$tmpDir, [string]$mdContent) {
        $this.TmpDir = $tmpDir
        $this.__MdContent = [StringBuilder]::new($mdContent, $mdContent.Length * 2)
    }

    <#
    Método estático para processar o conteúdo Markdown.
    Ele cria uma instância de MdParser, incorpora includes e ajusta classes.

    Args:
        tmpDir (string): Diretório temporário/base
        mdContent (string): Conteúdo markdown a processar

    Returns:
        string: Conteúdo processado.
    #>
    static [string] Parser([string]$tmpDir, [string]$mdContent) {
        $mdParser = [MdParser]::new($tmpDir, $mdContent)
        $mdParser.IncorporarIncludes()
        $mdParser.AjustarClasses()
        $mdParser.ReplaceHorizontalLines()
        return $mdParser.__MdContent.ToString()
    }

    <#
    IncorporarIncludes:
    Procura diretivas !!!__ INCLUDE "arquivo" __!!! no conteúdo e substitui pelo 
    conteúdo do arquivo indicado.
    #>
    hidden [void] IncorporarIncludes() {
        $matchesLst = [MdRegEx]::Includes.Matches($this.__MdContent.ToString())
        while ($matchesLst.Count -gt 0) {
            foreach ($m in $matchesLst) {
                $fullMatch     = $m.Groups[0].Value
                $relatFileName = $m.Groups[1].Value
                if ($relatFileName.EndsWith('.template.md')) {
                    $fullFileName = Join-Path -Path $this.TmpDir -ChildPath "templates\$relatFileName"
                } else {
                    $fullFileName = Join-Path -Path $this.TmpDir -ChildPath $relatFileName
                }
                try {
                    $fileContent = Get-Content -Path $fullFileName -Raw -ErrorAction Stop
                    $this.__MdContent.Replace($fullMatch, $fileContent)
                } catch {
                    Write-Error "INCLUDE não encontrado '$relatFileName'"
                    exit 1
                }
            }
            $matchesLst = [MdRegEx]::Includes.Matches($this.__MdContent.ToString())
        }
    }

    <#
    AjustarClasses:
    Substitui padrões [!class conteudo!] no markdown por <span class="class">conteudo</span>.
    Caso seja @@@[class conteudo]@@@, mantém marcação interna para posterior tratamento.
    #>
    hidden [void] AjustarClasses() {
        $matchesLst = [MdRegEx]::Klass.Matches($this.__MdContent.ToString())
        if ($matchesLst.Count -gt 0) {
            foreach ($m in $matchesLst) {
                $fullMatch = $m.Groups[0].Value
                $klass     = $m.Groups[2].Value
                $content   = $m.Groups[3].Value
                if ($m.Groups[1].Value -eq '[!') {
                    # Substitui por <span class="klass">conteudo</span>
                    $this.__MdContent.Replace($fullMatch, "<span class=`"$klass`">$content</span>")
                } else {
                    $this.__MdContent.Replace($fullMatch, "[!$klass $content!]")
                }
            }
        }
    }

    hidden [void] ReplaceHorizontalLines() {
        $matchesLst = [MdRegEx]::ReplaceHLine.Matches($this.__MdContent.ToString())
        $offset = 0

        foreach ($m in $matchesLst) {
            $fullMatch    = $m.Groups[0].Value
            $heightGroup  = $m.Groups['height']
            $colorGroup   = $m.Groups['color']
            $yGroup       = $m.Groups['y']
            $topGroup     = $m.Groups['top']
            $bottomGroup  = $m.Groups['bottom']

            $klass = @(
                "ca-hr"
                if ($heightGroup.Success) { "ca-$($heightGroup.Value)" }
                if ($colorGroup.Success)  { "ca-$($colorGroup.Value)" }
                if ($yGroup.Success)      { "my-$($yGroup.Value)" }
                if ($topGroup.Success)    { "mt-$($topGroup.Value)" }
                if ($bottomGroup.Success) { "mb-$($bottomGroup.Value)" }
            ) -join ' '

            $replacement = "`n<hr class=`"$klass`">`n"
            $startIndex = $m.Index + $offset
            # Usando Replace com startIndex e count
            $this.__MdContent.Replace($fullMatch, $replacement, $startIndex, $fullMatch.Length)
            # Atualiza o offset baseado na diferença de tamanho
            $offset += ($replacement.Length - $fullMatch.Length)
        }
    }
}
