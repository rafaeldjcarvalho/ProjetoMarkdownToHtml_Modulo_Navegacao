using namespace System.Text
using namespace System.Text.RegularExpressions

using module .\MdRegEx.psm1


class ToCGenerator {

    static [StringBuilder] InsertToc([StringBuilder]$sb, [System.Collections.Generic.List[Tuple[string, string, int]]]$toc, [int]$maxLevel = 3) {
        $tocText = [ToCGenerator]::GenerateTocString($toc, $maxLevel)
        return [MdRegEx]::ToC.Replace($sb.ToString(), $tocText)
    }

    hidden static [string] GenerateTocString([System.Collections.Generic.List[Tuple[string, string, int]]]$toc, [int]$maxLevel) {
        if ($toc.Count -eq 0) {
            return ""
        }

        # Estimativa do tamanho do StringBuilder
        $estimatedSize = [ToCGenerator]::EstimateStringBuilderSize($toc, $maxLevel)
        $sb = [StringBuilder]::new($estimatedSize)
        
        $sb.AppendLine("`n<!-- Table of Contents -->")

        $currentLevel = 0
        $levelCounts = New-Object 'System.Collections.Generic.Dictionary[int, int]'

        foreach ($item in $toc) {
            $text = $item.Item1
            $id = $item.Item2
            $level = $item.Item3

            if ($level -gt $maxLevel) {
                continue
            }

            # Ajusta os níveis e abre/fecha as tags <ul> e <li>
            $sb.Append([ToCGenerator]::AdjustLevels($currentLevel, $level))

            # Atualiza a contagem do nível atual
            if (-not $levelCounts.ContainsKey($level)) {
                $levelCounts[$level] = 0
            }
            $levelCounts[$level]++

            # Zera contadores de níveis mais baixos
            $keysToReset = $levelCounts.Keys | Where-Object { $_ -gt $level }
            foreach ($key in $keysToReset) {
                $levelCounts[$key] = 0
            }

            # Adiciona o item atual ao ToC
            $sb.AppendFormat("<li><a href=`"#$id`">$text</a>")

            $currentLevel = $level
        }

        # Fecha todas as tags <ul> e <li> pendentes
        $sb.Append([ToCGenerator]::CloseRemainingTags($currentLevel))

        $sb.AppendLine("`n")
        return $sb.ToString()
    }

    # Função auxiliar para ajustar os níveis e abrir/fechar tags <ul> e <li>
    hidden static [string] AdjustLevels([int]$currentLevel, [int]$newLevel) {
        $sb = [StringBuilder]::new()

        if ($newLevel -gt $currentLevel) {
            # Abre novos níveis
            for ($i = $currentLevel + 1; $i -le $newLevel; $i++) {
                # Só adiciona <ul> se não for o primeiro nível
                if ($i -ne 1) {
                    $sb.AppendLine("<ul>")
                }
            }
        } elseif ($newLevel -lt $currentLevel) {
            # Fecha níveis
            for ($i = $currentLevel; $i -gt $newLevel; $i--) {
                $sb.AppendLine("</li>")
                $sb.AppendLine("</ul>")
            }
            $sb.AppendLine("</li>") # Fecha o item do nível anterior
        } else {
            # Fecha o item anterior se estiver no mesmo nível, exceto o nível 0
            if ($currentLevel -ne 0) {
                $sb.AppendLine("</li>")
            }
        }
        return $sb.ToString()
    }

    # Função auxiliar para fechar todas as tags <ul> e <li> pendentes
    hidden static [string] CloseRemainingTags([int]$currentLevel) {
        $sb = [StringBuilder]::new()
        for ($i = $currentLevel; $i -ge 1; $i--) {
            $sb.AppendLine("</li>")
            $sb.AppendLine("</ul>")
        }
        return $sb.ToString()
    }

    # Função para estimar o tamanho inicial do StringBuilder com folga
    hidden static [int] EstimateStringBuilderSize([System.Collections.Generic.List[Tuple[string, string, int]]]$toc, [int]$maxLevel) {
        $totalTextLength = 0
        $maxIdLength = 0

        foreach ($item in $toc) {
            $totalTextLength += $item.Item1.Length
            $maxIdLength = [Math]::Max($maxIdLength, $item.Item2.Length)
        }

        # Estimativa para cada item:
        #   - Tamanho do texto: $totalTextLength
        #   - Tamanho do ID (máximo): $maxIdLength
        #   - Espaço para as tags <li><a href="#...</a></li>:  ~ 30 caracteres
        #   - Espaço para numeração (se houver): ~ 10 caracteres (chute)
        #   - Multiplicador para o nível máximo (considerando tags <ul></ul>): $maxLevel * 10
        $estimatedItemSize = $totalTextLength + ($maxIdLength * $toc.Count) + (30 * $toc.Count) + (10 * $toc.Count) + ($maxLevel * 10 * $toc.Count)

        # Adiciona uma folga de 50% para garantir
        $estimatedSize = [int]($estimatedItemSize * 1.5)

        # Garante um tamanho mínimo para evitar muitas realocações
        $minimumSize = 1024

        return [Math]::Max($estimatedSize, $minimumSize)
    }
}