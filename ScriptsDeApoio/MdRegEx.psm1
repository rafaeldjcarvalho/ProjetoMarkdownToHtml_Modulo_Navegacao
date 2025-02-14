class MdRegEx {
    # Correspondência para a diretiva INCLUDE em arquivos markdown
    static [regex] $Includes = [regex]::new('!!!__\s+INCLUDE\s+"([^"]+)"\s+__!!!', 'Compiled, IgnoreCase')
    # Exemplo: !!!__ INCLUDE "file.md" __!!!

    # Correspondência para a diretiva IMPORT em arquivos markdown
    static [regex] $Imports = [regex]::new('!!!__\s+IMPORT\s+"([^"]+)"\s+__!!!', 'Compiled, IgnoreCase')
    # Exemplo: !!!__ IMPORT "file.md" __!!!

    # Correspondência para definições de classe personalizadas em arquivos markdown
    static [regex] $Klass = [regex]::new('(\[!|@@@\[)([^\s\]]+)\s+([^\]]+?)(\!\]|\]@@@)', 'Compiled')
    # Exemplo: [!className some content!]

    # Correspondência para cabeçalhos de seção HTML com atributos id e class opcionais
    static [regex] $Section = [regex]::new('(?s)<h([1-6])\s*(?:id="([^"]+)")?\s*(?:class="([^"]+)")?\s*(?:([^>]+)?)>\s*(.+?)\s*<\/h\1>', 'Compiled, IgnoreCase')
    # Exemplo: <h1 id="header" class="title">Conteúdo do Cabeçalho</h1>

    # Correspondência para o atributo id em tags HTML
    static [regex] $Id = [regex]::new('id="([^"]+)"', 'Compiled, IgnoreCase')
    # Exemplo: <div id="uniqueId">

    # Correspondência e remoção de tags de link CSS específicas
    static [regex] $RemoveAulasCss = [regex]::new('<link href=".*/_aulas\.css" rel="stylesheet">', 'Compiled, IgnoreCase')
    # Exemplo: <link href="/path/_aulas.css" rel="stylesheet">

    # Correspondência para cabeçalhos markdown
    static [regex] $MdHeaders = [regex]::new('^----*\s*[\s\S]*?----*\s*', 'Compiled, Multiline')
    # Exemplo: ---- Cabeçalho ----

    # Correspondência para linhas horizontais em markdown
    static [regex] $ReplaceHLine = [regex]::new('\n--h:(?<height>\w+)(?:--c:(?<color>\w*))?(?:--y:(?<y>\w*))?(?:--t:(?<top>\w*))?(?:--b:(?<bottom>\w*))?--+(?![-\w])\s*\n', 'Compiled, Singleline')
    # Exemplo: 
    # --h:thin--
    # --h:2--
    # --h:2--c:orange--
    # --h:thin--c:orange--y:2--
    # --h:thin--c:orange--t:2--
    # --h:thin--c:orange--b:2--
    # --h:thin--c:orange--t:2--b:2--
    # --h:thin--y:2--
    # --h:thin--t:2--
    # --h:thin--b:2--
    # --h:thin--t:2--b:2--
    # --h:thin--t:2--b:2-----------------------

    # Correspondência para links markdown e substituição de extensões .md
    static [regex] $ReplaceMarkdownLinks = [regex]::new('href="([^"]+)\.md(#\S*)?"', 'Compiled, IgnoreCase')
    # Exemplo: href="file.md#section"

    # Correspondência para tags de fechamento de <pre> e <code>
    static [regex] $Code = [regex]::new('</pre>\s*</code>', 'Compiled, IgnoreCase')
    # Exemplo: </pre></code>

    # Correspondência e atualização de fontes de ativos
    static [regex] $UpdateAssetsSource = [regex]::new('(src|href|xlink:href)=("({workdir}|%7Bworkdir%7D)?[^"]+")', 'Compiled, IgnoreCase')
    # Exemplo: src="{workdir}/image.png"

    # Extração do conteúdo do corpo de um arquivo markdown
    static [regex] $ExtractBody = [regex]::new('<main class="[^"]*markdown-body[^>]*?>([\s\S]*?)</main>', 'Singleline, IgnoreCase')
    # Exemplo: <main class="markdown-body">Conteúdo</main>

    # Correspondência para o texto interno de tags <h1>
    static [regex] $h1InnerText = [regex]::new('<h1[^>]*>(.*?)</h1>', 'Singleline, IgnoreCase')
    # Exemplo: <h1>Cabeçalho</h1>

    # Correspondência para tags de script com atributos src
    static [regex] $Script = [regex]::new('<script.*?src=["''](.*?)["''].*?>.*?</script>', 'Compiled, IgnoreCase')
    # Exemplo: <script src="script.js"></script>

    # Correspondência para tags de link com atributos href
    static [regex] $Link = [regex]::new('<link.*?href=["''](.*?)["''].*?>', 'Compiled, IgnoreCase')
    # Exemplo: <link href="style.css">

    # Correspondência para tags de estilo e seu conteúdo
    static [regex] $Style = [regex]::new('<style.*?>(.*?)</style>', 'Compiled, IgnoreCase')
    # Exemplo: <style>body {}</style>

    # Correspondência para tags de script sem atributos src
    static [regex] $ScriptContent = [regex]::new('<script(?!.*?src=["'']).*?>(.*?)</script>', 'Compiled, IgnoreCase')
    # Exemplo: <script>console.log('Hello');</script>

    # Correspondência para atributos src com URLs HTTP
    static [regex] $HttpSrc = [regex]::new('<.*?\bsrc="((https?):\/\/[^"]+)".*?>', 'Compiled, IgnoreCase')
    # Exemplo: <img src="http://example.com/image.png">

    # Correspondência e remoção de números iniciais de uma string
    static [regex] $RemoveInitialNumbers = [regex]::new('^\s*\d+[\.\-]?\s*', 'Compiled')
    # Exemplo: "123-abc" -> "abc"

    # Correspondência e substituição de espaços por hífens
    static [regex] $ReplaceSpaces = [regex]::new('\s+', 'Compiled')
    # Exemplo: "a b c" -> "a-b-c"

    # Correspondência e remoção de caracteres inválidos
    static [regex] $RemoveInvalidChars = [regex]::new('[^a-zA-Z0-9\-]', 'Compiled')
    # Exemplo: "a@b#c" -> "abc"

    # Correspondência e substituição de múltiplos hífens por um único hífen
    static [regex] $ReplaceMultipleDashes = [regex]::new('\-+', 'Compiled')
    # Exemplo: "a--b---c" -> "a-b-c"

    # Correspondência e remoção de hífens do início e do fim de uma string
    static [regex] $TrimDashes = [regex]::new('^\-|\-$', 'Compiled')
    # Exemplo: "-abc-" -> "abc"

    # Garante que a string comece com uma letra
    static [regex] $EnsureStartsWithLetter = [regex]::new('^[^a-zA-Z]+', 'Compiled')
    # Exemplo: "123abc" -> "abc"

    # Correspondência e remoção de diacríticos de uma string
    static [regex] $RemoveDiacritics = [regex]::new('\p{M}', 'Compiled')
    # Exemplo: "café" -> "cafe"

    static [regex] $ToC = [regex]::new('!!!__ ToC __!!!', 'Compiled, IgnoreCase')
}
