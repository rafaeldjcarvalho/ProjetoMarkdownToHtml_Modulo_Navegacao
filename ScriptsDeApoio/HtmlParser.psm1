using namespace System.Text
using namespace System.Text.RegularExpressions

using module .\MdRegEx.psm1
using module .\ToCGenerator.psm1


class HtmlProcessor {
    [StringBuilder] $HtmlContent

    <#
    Construtor de HtmlProcessor.

    Args:
        htmlContent (StringBuilder): Conteúdo HTML a ser processado.
    #>
    HtmlProcessor([StringBuilder]$htmlContent) {
        $this.HtmlContent = $htmlContent
    }

    <#
    Parser estático que orquestra todo o processamento HTML:
    - Remove link para _aulas.css
    - Substitui diretivas de importação
    - Adiciona highlight.js se necessário
    - Atualiza caminhos de assets
    - Substitui linhas horizontais
    - Substitui links .md por .html

    Args:
        htmlContent (StringBuilder): Conteúdo HTML inicial
        relatPath (string): Caminho relativo do arquivo HTML

    Returns:
        StringBuilder: Conteúdo HTML final
    #>
    static [StringBuilder] Parser([StringBuilder]$htmlContent, [string]$relatPath) {
        $htmlProcessor = [HtmlProcessor]::new($htmlContent)
        $htmlProcessor.RemoveAulasCssLink()
        $htmlProcessor.ReplaceImportDirectives()
        $htmlProcessor.AddHighlightJsImport()
        $htmlProcessor.UpdateAssetPaths($relatPath)
        # $htmlProcessor.ReplaceHorizontalLines()
        $htmlProcessor.ReplaceMarkdownLinks()
        return $htmlProcessor.HtmlContent
    }

    <#
    Método auxiliar para aplicar substituições Regex no HtmlContent (StringBuilder).
    Evita reescrita de código.

    Args:
        pattern (Regex): Expressão regular a aplicar
        replacement (string): Texto de substituição
    #>
    hidden [void] RegexReplaceContent([Regex]$pattern, [string]$replacement) {
        $content = $this.HtmlContent.ToString()
        $content = $pattern.Replace($content, $replacement)
        $this.HtmlContent = [StringBuilder]::new($content)
    }

    <#
    Remove o link para o arquivo _aulas.css usando a regex pré-definida em MdRegEx.
    #>
    hidden [void] RemoveAulasCssLink() {
        $this.RegexReplaceContent([MdRegEx]::RemoveAulasCss, '')
    }

    <#
    Substitui diretivas !!!__ IMPORT "biblioteca" __!!! pelos scripts correspondentes.
    Assume que $global:imports esteja definido.
    #>
    hidden [void] ReplaceImportDirectives() {
        $importsAqui = '<!-- JavaScript IMPORTs -->'
        $htmlString = $this.HtmlContent.ToString()
        $matchesLst = [MdRegEx]::Imports.Matches($htmlString)

        $scriptTags = [StringBuilder]::new()
        foreach ($m in $matchesLst) {
            $biblioteca = $m.Groups[1].Value
            if ($global:imports.ContainsKey($biblioteca)) {
                $scriptTag = $global:imports[$biblioteca]
                $scriptTags.AppendLine($scriptTag) | Out-Null
            }
        }

        if ($scriptTags.Length -gt 0) {
            $newContent = $this.HtmlContent.ToString().Replace($importsAqui, "$importsAqui`n$($scriptTags.ToString())")
            $this.HtmlContent = [StringBuilder]::new($newContent)
        }
    }

    <#
    Adiciona import do highlight.js se encontrar tags <pre><code>.
    Usa -imatch para ignorar case.
    #>
    hidden [void] AddHighlightJsImport() {
        $html = $this.HtmlContent.ToString()
        $matchesLst = [MdRegEx]::Code.Matches($html)
        # if ($matchesLst.Count -gt 0) {
            $scriptTag = $global:imports['highlight']
            $importsAqui = '<!-- JavaScript IMPORTs -->'
            $newContent = $html.Replace($importsAqui, "$importsAqui`n$scriptTag")
            $this.HtmlContent = [StringBuilder]::new($newContent)
        # }
    }

    <#
    Atualiza caminhos de assets substituindo {workdir} por caminho relativo calculado.
    #>
    hidden [void] UpdateAssetPaths([string]$relatPath) {
        $depth = ($relatPath -split '[\\/]').Count - 1
        $relatPathPrefix = ('../' * $depth)

        $content = $this.HtmlContent.ToString()
        $matchesLst = [MdRegEx]::UpdateAssetsSource.Matches($content)

        # Ajusta atributos que contêm {workdir}
        foreach ($m in $matchesLst) {
            $fullAttr = $m.Groups[0].Value
            $workdir = $m.Groups[3].Value

            if ( ! [string]::IsNullOrEmpty($workdir) ) {
                $newAttr = $fullAttr.Replace($workdir, $relatPathPrefix)
                $content = $content.Replace($fullAttr, $newAttr)
            }
        }

        # Aplicar substituição de links .md => .html
        $content = [MdRegEx]::ReplaceMarkdownLinks.Replace($content, 'href="$1.html$2"')

        $this.HtmlContent = [StringBuilder]::new($content)
    }

    <#
    Já aplicado também no UpdateAssetPaths, mas caso precise aqui:
    Substitui links .md por .html.
    #>
    hidden [void] ReplaceMarkdownLinks() {
        # Caso haja substituições remanescentes:
        $this.RegexReplaceContent([MdRegEx]::ReplaceMarkdownLinks, 'href="$1.html$2"')
    }
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class AddToggleSections {

    static [Tuple[StringBuilder, System.Collections.Generic.List[Tuple[string, string, int]]]] Parser([string]$htmlContent) {
        # Pilha para controle de níveis de seção (agora com nível)
        $sectionStack = New-Object System.Collections.Generic.Stack[PSCustomObject]

        $sectionTag = 'section'
        $headerTag = 'header'
        $articleTag = 'article'

        # Encontrar todas as seções (h1..h6)
        $matchesLst = [MdRegEx]::Section.Matches($htmlContent)

        # Vamos reconstruir o conteúdo final do zero
        # Estratégia: Percorrer o texto, colar trechos entre matches, inserir seções.
        $output = [StringBuilder]::new($htmlContent.Length * 2)
        $lastIndex = 0

        # Lista para armazenar as tags h* (Table of Contents)
        $toc = New-Object 'System.Collections.Generic.List[System.Tuple[string, string, int]]'

        foreach ($m in $matchesLst) {
            $level      = [int]$m.Groups[1].Value
            $idMatch    = $m.Groups[2]
            $klass      = $m.Groups[3].Value
            $attributes = $m.Groups[4].Value
            $innerText  = $m.Groups[5].Value

            # Determinar ID
            $id = [AddToggleSections]::GetSectionId($idMatch, $innerText, $true)
            $sectionId = "section-$id"

            # Adicionar a tag h* à lista $toc, independentemente de ca-ignore-fold
            if (-not $klass.Contains('ca-ignore-toc')) {
                $toc.Add([Tuple]::Create($innerText, $sectionId, $level))
            }

            if ($klass.Contains('ca-ignore-fold')) { # Se a tag h* tem a classe 'ca-ignore-fold'
                # Primeiro, escreve o que vem antes da seção atual
                [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $m.Index)

                # Adicionar o ID na tag h*
                if (-not $idMatch.Success) {
                    $attributes += " id=`"$id`""
                }

                # Insere a tag h* com o ID e outros atributos
                $output.Append("<h$level $attributes>$innerText</h$level>")
                $lastIndex = $m.Index + $m.Length
                continue
            }

            # Primeiro, escreve o que vem antes da seção atual
            [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $m.Index)

            # Fechar seções anteriores se necessário
            [AddToggleSections]::ClosePreviousSections($output, $sectionStack, $level, $articleTag, $sectionTag)

            # Se estiver no mesmo nível, fechar o article anterior
            [AddToggleSections]::ClosePreviousArticleIfSameLevel($output, $sectionStack, $level, $articleTag)

            # Abrir nova seção
            [AddToggleSections]::OpenNewSection($output, $sectionStack, $level, $sectionId, $sectionTag)

            # Insere o cabeçalho da seção com o título e ícone
            [AddToggleSections]::InsertSectionHeader($output, $headerTag, $level, $m, $innerText, $id)

            # Início do conteúdo da seção
            $output.AppendLine("<$articleTag class=`"ca-article`">")

            $lastIndex = $m.Index + $m.Length
        }

        # Adicionar o restante do conteúdo e fechar seções abertas
        [AddToggleSections]::AppendRemainingContentAndCloseSections($output, $htmlContent, $lastIndex, $sectionStack, $articleTag, $sectionTag)

        return [Tuple]::Create($output, $toc)
    }

    hidden static AppendContent([StringBuilder]$output, [string]$htmlContent, [int]$startIndex, [int]$endIndex) {
        if ($startIndex -lt $endIndex) {
            $output.Append($htmlContent.Substring($startIndex, $endIndex - $startIndex))
        }
    }

    hidden static [string] GetSectionId([System.Text.RegularExpressions.Group]$idMatch, [string]$innerText, [bool]$normalizar) {
        if ($idMatch.Success) {
            $id = $idMatch.Value
        } else {
            $id = $innerText
        }

        # Remover números iniciais do innerText
        $id = [MdRegEx]::RemoveInitialNumbers.Replace($id, '')

        if ($normalizar) {
            # Capturar innerText, remover espaços duplicados, REMOVER ACENTOS (agora somente se $normalizar for true)
            $id = [AddToggleSections]::RemoveDiacritics($innerText)
            $id = [MdRegEx]::ReplaceSpaces.Replace($id, '-')
            $id = [MdRegEx]::RemoveInvalidChars.Replace($id, '')
            $id = [MdRegEx]::ReplaceMultipleDashes.Replace($id, '-')
            $id = [MdRegEx]::TrimDashes.Replace($id, '')
        }

        # Garantir que o ID comece com uma letra
        $id = [MdRegEx]::EnsureStartsWithLetter.Replace($id, '')
        return $id.ToLower()
    }

    hidden static [string] RemoveDiacritics([string]$txt) {
        return [MdRegEx]::RemoveDiacritics.Replace($txt.Normalize([Text.NormalizationForm]::FormD), "")
    }

    hidden static ClosePreviousSections([StringBuilder]$output, [System.Collections.Generic.Stack[PSCustomObject]]$sectionStack, [int]$currentLevel, [string]$articleTag, [string]$sectionTag) {
        while ($sectionStack.Count -gt 0 -and $currentLevel -le $sectionStack.Peek().Level) {
            [AddToggleSections]::CloseSingleSection($output, $sectionStack, $articleTag, $sectionTag)
        }
    }

    hidden static CloseSingleSection([StringBuilder]$output, [System.Collections.Generic.Stack[PSCustomObject]]$sectionStack, [string]$articleTag, [string]$sectionTag) {
        $sectionInfo = $sectionStack.Pop()
        $output.AppendLine("    </$articleTag>")
        $output.AppendLine("</$sectionTag> <!-- end.section '$($sectionInfo.Id)' -->")
    }

    hidden static ClosePreviousArticleIfSameLevel([StringBuilder]$output, [System.Collections.Generic.Stack[PSCustomObject]]$sectionStack, [int]$currentLevel, [string]$articleTag) {
        if ($sectionStack.Count -gt 0 -and $currentLevel -eq $sectionStack.Peek().Level) {
            $output.AppendLine("</$articleTag>")
        }
    }

    hidden static OpenNewSection([StringBuilder]$output, [System.Collections.Generic.Stack[PSCustomObject]]$sectionStack, [int]$level, [string]$sectionId, [string]$sectionTag) {
        $sectionStack.Push(@{ Id = $sectionId; Level = $level })
        $output.AppendLine()
        $output.AppendLine("<$sectionTag id=`"$sectionId`" class=`"ca-toggle-section`">")
    }

    hidden static InsertSectionHeader([StringBuilder]$output, [string]$headerTag, [int]$level, [System.Text.RegularExpressions.Match]$m, [string]$innerText, [string]$id) {
        $idMatch = $m.Groups[2]
        $class = $m.Groups[3].Value
        $otherAttributes = $m.Groups[4].Value
    
        # Construir atributos, priorizando id e depois class
        $existingAttributes = ""
        if ($idMatch.Success) {
            $existingAttributes += " id=`"$($idMatch.Value)`""
        } else {
            $existingAttributes += " id=`"$id`""
        }
    
        if ($class) {
            $existingAttributes += " class=`"$class`""
        }
    
        if ($otherAttributes) {
            $existingAttributes += " $otherAttributes"
        }
    
        $output.AppendLine(
            "<$headerTag class=`"ca-header`">`n" + `
            "    <h$level$existingAttributes><svg class=`"ca-fold-icon`"><use href=`"#icon-arrow-right`"></use></svg> $innerText</h$level>" + `
            "</$headerTag>")
    }

    hidden static AppendRemainingContentAndCloseSections([StringBuilder]$output, [string]$htmlContent, [int]$lastIndex, [System.Collections.Generic.Stack[PSCustomObject]]$sectionStack, [string]$articleTag, [string]$sectionTag) {
        $mainEndIndex = $htmlContent.IndexOf("<!-- end-main.markdown-body -->", $lastIndex)
        $mainEndMarker = "<!-- end-main.markdown-body -->"

        if ($sectionStack.Count -gt 0) {
            # Com seções abertas
            [AddToggleSections]::AppendContentWithOpenSections($output, $htmlContent, $lastIndex, $mainEndIndex, $mainEndMarker)
        } else {
            # Sem seções abertas
            [AddToggleSections]::AppendContentWithoutOpenSections($output, $htmlContent, $lastIndex, $mainEndIndex, $mainEndMarker)
        }

        # Fechar seções ainda abertas (se houver)
        while ($sectionStack.Count -gt 0) {
            [AddToggleSections]::CloseSingleSection($output, $sectionStack, $articleTag, $sectionTag)
        }
    }

    hidden static AppendContentWithOpenSections([StringBuilder]$output, [string]$htmlContent, [int]$lastIndex, [int]$mainEndIndex, [string]$mainEndMarker) {
        if ($mainEndIndex -ge 0) {
            # Adicionar o conteúdo restante até o marcador (INCLUSIVE o marcador) DENTRO da última seção
            [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $mainEndIndex + $mainEndMarker.Length)
            $lastIndex = $mainEndIndex + $mainEndMarker.Length
        } else {
            # Adicionar o restante do conteúdo após a última seção (caso não exista o marcador) DENTRO da última seção
            [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $htmlContent.Length)
        }
        # Adicionar o restante do conteúdo APÓS o marcador e ANTES de fechar as seções
        [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $htmlContent.Length)
    }

    hidden static AppendContentWithoutOpenSections([StringBuilder]$output, [string]$htmlContent, [int]$lastIndex, [int]$mainEndIndex, [string]$mainEndMarker) {
        if ($mainEndIndex -ge 0) {
            [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $mainEndIndex + $mainEndMarker.Length)
        } else {
            [AddToggleSections]::AppendContent($output, $htmlContent, $lastIndex, $htmlContent.Length)
        }
    }
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class HtmlParser {

    <#
    Parser:
    - Adiciona seções toggle
    - Processa HTML final (remove css, importa js, etc.)

    Args:
        htmlContent (string): Conteúdo HTML inicial.
        relatPath (string): Caminho relativo do arquivo HTML.

    Returns:
        Tuple[StringBuilder, List[Tuple[string, int]]]: 
            Item1: Conteúdo HTML final como StringBuilder.
            Item2: Lista de tags h* (Table of Contents) como uma lista de tuplas (string, int).
    #>
    static [StringBuilder] Parser([string]$htmlContent, [string]$relatPath) {
        $result = [AddToggleSections]::Parser($htmlContent)
        $sb = $result.Item1
        $toc = $result.Item2
        $sb = [HtmlProcessor]::Parser($sb, $relatPath)
        $sb = [ToCGenerator]::InsertToc($sb, $toc, 3)
        return $sb
    }
 
}
