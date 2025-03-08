--id: parte-2
--titulo: Parte 2

<!--Template: header() -->

<h2 class="ca-pg-title">Parte 2: Especificações Técnicas</h2>

!!!__ ToC __!!!

## 2.1. Tarefas de Pré-processamento para os Docs Markdown

Antes de converter os documentos Markdown em HTML é preciso pre-processá-los, para:

- Extrair os metadados do arquivo Markdown (.md)
- Realizar algumas substituições de texto de necessárias, p.ex. tags
- Processar algumas tags personalizadas

--h:thin----------------------------------------------------------------------------------

### 2.1.1. Extrair os metadados do arquivo Markdown (.md)

- Definir o título da página, autor, data de criação, data de atualização, keywords ...
- Otimizar o SEO (Search Engine Optimization, otimização para motores de busca), para ajudar os motores de busca (p.ex. Google) indexarem a página.
- Geração do Feed RSS, isto é, do arquivo `rss.xml`. Para facilitar a divulgação das atualizações de conteúdo do site.
- Geração do Sitemap e Robots.txt: os metadados são utilizados para criar o `sitemap.xml` e o arquivo `robots.txt`, essenciais para correta indexação do site pelos motores de busca. Para mais informações, ver (link)[sitemap.md].

--h:thin----------------------------------------------------------------------------------

#### Exemplo de Metadados em um arquivo Markdown

- Os metadados devem estar no início do documento, em um bloco especial denominado _front matter_. Abaixo, um exemplo ilustrativo:

```html
---
id: id-do-documento
title: "Exemplo Completo de Metadados"
description: "Um exemplo abrangente de metadados em um arquivo markdown."
sidebar_label: "Nome que você verá no sumário (ou barra de navegação) do site."
slug: /caminho-para-este-documento
date: 2024-10-01
author: "Seu Nome"
tags: ["exemplo", "markdown", "metadados"]
keywords: ["palavras-chave usadas pelos motores de busca", "markdown"]
image: /assets/img/miniatura-da-pagina-usada-em-compartilhamento.png

draft: false
freq_de_atualizacao: monthly
data_atualizacao: 2024-12-01
---

<!-- Restante do Markdown -->
```

- Os campos `freq_de_atualizacao` e `data_atualizacao` não são metadados padrão do Markdown.

- Tags vs. Keywords:
    - Tags: Utilizadas para organizar e categorizar o conteúdo dentro do site. Geralmente são visíveis aos usuários e facilitam a navegação.
    - Keywords: Destinadas a otimizar o SEO da página, auxiliando os motores de busca na indexação do conteúdo. Não são, em geral, visíveis para os usuários.
    - draft: Indica se o documento é um rascunho (draft=true) ou está pronto para publicação (draft=false). O script de processamento deve verificar este campo antes de converter o documento. Se draft=true, o documento não deve ser publicado.

--h:thin----------------------------------------------------------------------------------

#### Exemplo de um Feed RSS, arquivo `rss.xml`

```rss
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
    <channel>
        <title>Nome do Seu Site</title>
        <link>http://www.seusite.com.br</link>
        <description>Descrição do conteúdo do seu site</description>
        <language>pt-br</language>
        <item>
            <title>Título da Postagem</title>
            <link>http://www.seusite.com.br/postagem1</link>
            <description>Resumo da primeira postagem.</description>
            <pubDate>Mon, 02 Dec 2024 17:21:00 GMT</pubDate>
            <guid>http://www.seusite.com.br/postagem1</guid>
        </item>
        <item>
            <title>Título da Segunda Postagem</title>
            <link>http://www.seusite.com.br/postagem2</link>
            <description>Resumo da segunda postagem.</description>
            <pubDate>Mon, 02 Dec 2024 16:00:00 GMT</pubDate>
            <guid>http://www.seusite.com.br/postagem2</guid>
        </item>
        <!-- Mais itens podem ser adicionados aqui -->
    </channel>
</rss>
```

--h:thin----------------------------------------------------------------------------------

### 2.1.2. Algumas Substituições

- [Substitua as tags `---` por `<hr>`]{.d-2}: O `pandoc`, programa utilizado para converter arquivos Markdown (.md) em HTML, não reconhece a tag `---` (linha horizontal). Portanto, o script precisa substitui-lá por `<hr>` para evitar erros durante a conversão. Sugestão, utilização da expressão regular `^----*$`, que identifica todas as sequências de três ou mais hífens consecutivos `---` que iniciam uma linha e são finalizadas com um hífen.

- [Substituir todos os hyperlinks terminados em `.md`]{.d-2} (extensão do markdown) por `.html`.

--h:thin----------------------------------------------------------------------------------

### 2.1.3. Processamento das tags

Exemplos de substituições a serem realizadas pelo script durante o processamento do markdown (.md):

- Ao encontrar a tag `[! include "header.template.md" !]`, o conteúdo do arquivo `header.template.md` (cabeçalho da página) deve ser incluído no local da tag. Sugestão, guarde os templates na pasta `./templates`.
- Ao encontrar `@@@[quest 3.1.]@@@`, a tag deve ser substituída por `<span class="quest">3.1.</span>`.
- Ao encontrar `@@@[h1.titulo Título do Doc]@@@`, substituir por `<h1 class="titulo">Título do Doc</h1>`. O mesmo vale para outras tags, p.ex h2, h3, h4 ... span ...
- Para `@@@[beg div.quest-dificil]@@@ ... bloco de código ... @@@[end div.quest-dificil]@@@`, substituir por `<div class="quest-dificil"> ... </div>`. Para facilitar, considere que o usuário fecha corretamente as tags, por exemplo, todas os divs são acertos e fechados corretamente.
- Por simplificação, considere que as diretivas (ou tags de template) `[!` e `!]` não aparecem no texto, eliminando a necessidade de tratamento de caracteres de escape.

--h:thin----------------------------------------------------------------------------------

## 2.2. Customização Visual

- Aplicar estilos CSS para melhorar a aparência das páginas HTML. Sugestão: github-dark-theme e github-light-theme.
- Permitir que o usuário escolha entre pelo menos dois temas pré-definidos ou adicione seu próprio tema personalizado, arquivo `custom.css`.
- A configuração do website deverá ser feita através do arquivo `config.yml`. Exemplo de um arquivo de configuração:

```yml
site_name: Meu Site Estático
base_url: http://www.meusite.com
author: "Seu Nome"
description: "Descrição do site estático"
favicon: "logo-ifs.svg"

toc_depth: 3

# Configurações de construção
build:
    minify_html: true
    minify_css: true
    minify_js: true
    generate_sitemap: true   # gerar sitemap.xml
    generate_robots: true    #       robots.txt  
    generate_feed_rss: true  #       rss.xml

    add_local_search: true   # adicionar o recurso de busca local

    optimze_imgs: true       # otimizar imagens para carregamento rápido

# Entre outras configurações ...
```

--h:thin----------------------------------------------------------------------------------

## 2.3. Realce de Sintaxe de Código (sintax highlight)

Para melhorar a legibilidade e compreensão do código, utilizando diversas linguagens de programação.

- É muito simples, basicamente, consiste em importar a biblioteca js `hightlight.js` sempre que seu script encontrar a tag `</code></pre>` no arquivo HTML gerado.
    - `hightlight.js`, ver [https://github.com/highlightjs/highlight.js](https://github.com/highlightjs/highlight.js).
    - Essa biblioteca requer o import do estilo CSS github-dark.

--h:thin----------------------------------------------------------------------------------

## 2.4. Navegação

Geração automática do ToC, menu de navegação e breadcrumbs para facilitar a navegação no site.

--h:thin----------------------------------------------------------------------------------

### 2.4.1. ToC (Table of Contents, tabela de conteúdo) da página

- Se o documento Markdown, conter a tag `@@@[__ ToC __]@@@`, o script deve construir a tabela ToC e coloca-la na barra lateral direita da página.
- A ToC é formada pelo título de todas as seções da página, h1, h2, ... até h6.
- Permita ao usuário definir o nível de profundidade do ToC através do arquivo `config.yml`, propriedade `toc_depth`, cujo valor padrão é 3, que equivale ao nível h3.
- Por exemplo, supondo o Markdown a seguir, vamos gerar seu ToC com nível de profundidade (toc_depth) = 3.

```html
# Título do documento, h1

@@@[__ ToC __]@@@

## Seção 1, h2
...
## Seção 2, h2
...
### SubSeção 2.1, h3
...
#### SubSubSeção 2.1.1, h4
<!-- `doc_depth=3`, não vai para o ToC -->
...
#### SubSubSeção 2.1.2, h4
<!-- `doc_depth=3`, não vai para o ToC -->
...
##### SubSubSubSeção 2.1.2.1, h5
<!-- `doc_depth=3`, não vai para o ToC -->
...
## Seção 3
...
```
    
- A tag `@@@[__ ToC __]@@@` (sumário) em um arquivo, resulta em um novo Markdown exibido a seguir.

```html
# Título do documento, h1

<!-- Sumário (ToC) gerado automaticamente --> 
- [Seção 1, h2]  <!-- Link para Seção 1 -->
- [Seção 2, h2]  <!-- Link para Seção 2 -->
    - [SubSeção 2.1, h3]
- [Seção 3, h2]

## Seção 1, h2
...
## Seção 2, h2
...
### SubSeção 2.1, h3
...
#### SubSubSeção 2.1.1, h4
<!-- `doc_depth=3`, não vai para o ToC -->
...
#### SubSubSeção 2.1.2, h4
<!-- `doc_depth=3`, não vai para o ToC -->
...
##### SubSubSubSeção 2.1.2.1, h5
<!-- `doc_depth=3`, não vai para o ToC -->
...
## Seção 3
...
```

--h:thin----------------------------------------------------------------------------------

### 2.4.2. Menu de Navegação

- O script deve gerar automaticamente o menu de navegação do site ("o sumário do site") para permitir o usuário navegar pelas páginas do site.
- O menu deve ser posicionado na barra lateral esquerda da página.

--h:thin----------------------------------------------------------------------------------

### 2.4.3. Breadcrumbs

- O script deve gerar os breadcrumbs (trilhas de navegação) para auxiliar na orientação do usuário dentro do site, proporcionando uma visualização clara do caminho percorrido. Exemplos de implementação podem ser encontrados em <a href="https://getbootstrap.com/docs/5.3/components/breadcrumb/#example" target="_blank">Bootstrap Breadcrumbs</a>.
- Os breadcrumbs devem ser posicionados logo após o início da tag main da página.

--h:thin----------------------------------------------------------------------------------

## 2.5. Busca Local

- Adicionar a funcionalidade de busca local para permitir que os usuários realizem pesquisas dentro do site. Para tal, utilize bibliotecas como:
    - **Lunr.js**: Detalhes e documentação disponíveis em [Lunr.js](https://lunrjs.com/). Nota: Para o correto funcionamento da biblioteca, é necessário abrir o site por meio de um servidor local. A forma mais simples de iniciar um servidor local é executando o seguinte comando no terminal na pasta de `index.html`: `python -m http.server 3000`. Posteriormente, abra o navegador e acesse `localhost:3000`.

--h:thin----------------------------------------------------------------------------------

## 2.6. Copiar Código

- Funcionalidade copiar código com um clique utilizando JavaScript.
- Basicamente consiste em uma função JavaScript que varre a página HTML após seu carregamento, buscando a classe `.div.sourceCode` para adicionar ao bloco o botão `Copiar Código` associado a função js `copiarCodigo`.

--h:thin----------------------------------------------------------------------------------

## 2.7. Otimização do site para carregamento rápido

### 2.7.1. Minificação de arquivos

Remove espaços em branco, comentários e quebras de linha dos arquivos CSS e JavaScript para reduzir seu tamanho.

- Utilize ferramentas como UglifyJS para JavaScript e cssnano para CSS. Exemplo de minificação:

```powershell
# Minificar JavaScript
uglifyjs script.js -o script.min.js -c -m

# Minificar CSS
cssnano estilo.css estilo.min.css
```

- [Redução de solicitações HTTP]{.d-2}: Após a minificação dos arquivos, busque combinar os arquivos CSS e JavaScript para diminuir o número de solicitações HTTP.

--h:thin----------------------------------------------------------------------------------

### 2.7.2. Otimização das Imagens

1. **Remoção de Metadados EXIF** (importante por questões de privacidade): Metadados EXIF (Exchangeable Image File Format) são informações embutidas nas imagens digitais que fornecem detalhes sobre como e quando a foto foi tirada, além das configurações da câmera usada. P.ex. data e hora de quando a foto foi tirada, localização geográfica (GPS), modelo da câmera e lente, ...

1. **Redimensionamento das imagens**: As imagens devem ser redimensionadas para corresponder exatamente ao tamanho em que serão exibidas na tela. Por exemplo, se uma imagem ocupa 640x480 pixels na página, mas possui uma resolução original de 4K (3840x2160 pixels), isso resulta em um tamanho de arquivo maior do que o necessário, prejudicando o tempo de carregamento. Redimensione a imagem para 640x480 pixels para agilizar o carregamento da página.

1. **Ajuste do DPI (Dots Per Inch)**: O DPI padrão é 96 DPI. No entanto, o sistema deve permitir que o usuário defina um valor padrão diferente no arquivo de configuração `config.yml`. Além disso, deve-se possibilitar que o usuário especifique o DPI de uma imagem individualmente.
    - **Qualidade de imagem e DPI adaptativo (IGNORAR)**. Adapte a qualidade da imagem com base nas condições da rede do usuário. Em resumo, você armazena várias versões da mesma imagem, cada uma gerada para uma dada velocidade de conexão. P.ex. redes lentas, recebem uma imagem de menor qualidade, agilizando assim o carregamento da página.

1. **Conversão automática das imagens para formatos modernos**: Adote formatos de imagem modernos, como o WebP, que proporcionam melhor compressão e qualidade. Para imagens vetoriais, aplique compressão sem perda de qualidade. Para imagens rasterizadas, utilize uma compressão em torno de 85%. A imagem final deve ser aquela com o menor tamanho de arquivo entre o original e o otimizado, mantendo sempre a mesma qualidade visual.

1. **Lazy Loading** (carregamento preguiçoso): Carrega as imagens apenas quando elas estão prestes a entrarem na área visível do usuário, agilizando o carregamento dos demais elementos da página.

1. **Exceções na otimização**: O usuário deve ter a opção de registrar exceções, indicando quais imagens não devem ser otimizadas. Isso é útil para casos onde a qualidade original da imagem é essencial e não pode ser comprometida.

1. **Sintaxe para inserção de imagens com ajustes**: Ao inserir imagens utilizando Markdown, a sintaxe padrão é: `![Texto Alternativo a Imagem](assets/imgs/imagem-test.jpg)`. Para incorporar os ajustes mencionados, a tag deve ser modificada para refletir as opções desejadas:
  
    - *Especificar a resolução da imagem*: `![Texto](assets/imgs/imagem-test.jpg)@[resolucao=640x480]`.

    - *Especificar o DPI da imagem*: `![Texto](assets/imgs/imagem-test.jpg)@[300dpi]`.
    
    - *Manter metadados EXIF*: `![Texto](assets/imgs/imagem-test.jpg)@[manter-exif]`. Mantém os metadados, mas realiza as otimizações. Nesse caso, dispare um WARNING para o usuário, alertando sobre as questões de privacidade e que os metadados estão sendo mantidos.

    - *Não otimizar a imagem*: `![Texto](assets/imgs/imagem-test.jpg)@[nao-otimizar]`. Neste caso, nenhuma otimização é realizada e o arquivo original é utilizado. OBS. os metadados EXIF são removidos. Para não remover os metadados `![Texto](assets/imgs/imagem-test.jpg)@[nao-otimizar + manter-exif]`.
  
    - *Não lazy loading*: `![Texto](assets/imgs/imagem-test.jpg)@[nao-lazy-loading]`. A imagem é carregada normalmente.

    - *Manter a resolução original*: `![Texto](assets/imgs/imagem-test.jpg)@[manter-resolucao]`. Aqui, o formato da imagem pode ser alterado (por exemplo, convertida para WebP) e o DPI pode ser ajustado, mas a resolução original é preservada.
  
    - *Manter o DPI original*: `![Texto](assets/imgs/imagem-test.jpg)@[manter-dpi]`. Semelhante ao item anterior, porém o DPI original é mantido enquanto outros aspectos podem ser otimizados.

    - **<b>Nota Importante</b>**
        - As opções podem ser combinadas através de `' + '` (com espaços). P.ex. para não otimizar a imagem & não lazy loading, `![Texto](assets/imgs/imagem-test.jpg)@[nao-otimizar + nao-lazy-loading]`.
        - As opções de não-otimização estão listadas acima. Caso o usuário digite outras opções, um erro deve ser lançado e o script interrompido.

--h:thin----------------------------------------------------------------------------------

## 2.8. Conversão de Markdown para HTML
  
Utilize o programa `pandoc` para converter arquivos markdown (.md) em arquivos HTML, garantindo que a conversão preserve a estrutura e a formatação dos documentos originais.

- O script deve buscar todos os documentos Markdown (.md) na pasta `./docs` e subpastas, convertendo-os em HTML.
- O site gerado deve ser armazenado em `./dist` (distribution). Mantendo a mesma hierarquia de diretórios de `./docs` (documents).

Como template para o pandoc sugiro o html a seguir.

```html
<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <title>$title$</title>

    <link rel="icon" href="{workdir}assets/logo-ifs.svg" type="image/svg+xml">

    <link rel="stylesheet" href="{workdir}assets/meu-estilo.min.css">
    <!-- IMPORTs CSS aqui -->
    
    <!-- IMPORTs Javascript no HEAD -->
    <!-- Análise se seus JS precisam ser incluídos no HEAD ou no BODY -->
</head>

<body>
    <main class="markdown-body">
        $body$
    </main>
    <!-- IMPORTs Javascript no BODY -->
    <script src="{workdir}assets/meu-script.min.js"></script>
</body>

</html>
```

Algumas considerações.

- `{workdir}` (diretório de trabalho): É uma variável de ambiente de meu script, usada realizar ajustes no caminho dos recursos (imagens, css, js ...).
- `<main class="markdown-body">`: Utilize a classe `markdown-body` apenas se estiver usando algum CSS baseado no github, que é meu caso.
- `<!-- IMPORTs CSS aqui -->`: Tag usada por meu script para localizar o local no qual os CSSs precisam ser inseridos.
- `<!-- IMPORTs Javascript no HEAD -->`: Similar a tag anterior. Define o local para insert dos JavaScript no `<head>`.
- `<!-- IMPORTs Javascript no BODY -->`: Define o local dos JavaScript antes do final da tag `</body>`.
- `meu-estilo.min.css`: Uma versão personalizada do github-dark.
- `meu-script.min.js`: Um merge minificado de meus scripts JavaScript.
- `$title$` e `$body$`: São variáveis do pandoc. O HTML gerado substitui a string $body$.

Para converter um doc Markdown em HTML usando Pandoc, pode utilizar o comando abaixo:

```powershell
.\pandoc.exe "exemplo.md" -o "exemplo.html" --title "Página Exemplo" --template "template.html"
```

--h:thin----------------------------------------------------------------------------------

#### Gerenciamento de Arquivos e Estrutura de Diretórios

- Após a conversão ainda é preciso copiar a pasta `./docs/assets` padrão para `./dist/assets`, a pasta de destino do site gerado.
- A pasta `./docs/assets` padrão é usada por todos os websites do gerador. 
- Relembrando, `./docs/assets` = 'recursos'. P.ex. imagens, CSS, JavaScript etc. Em geral, possui as subpastas: `img`, `css` e `js`.

--h:thin----------------------------------------------------------------------------------

## 2.9. Habilitação de cache no navegador

- Após a geração do site, gere um arquivo de otimização do servidor web voltado para seu site. Exiba as instruções de uso na tela do usuário para que ele tenha ciencia.
    
```apache
# Exemplo para servidor Apache
<IfModule mod_headers.c>
    <FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico)$">
        Header set Cache-Control "public, max-age=2592000"
    </FilesMatch>
</IfModule>
```

```apache
# Exemplo para servidor Nginx
server {
    # Outras configurações do servidor

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|webp)$ {
        expires 30d;
        add_header Cache-Control "public, max-age=2592000"; # 30 dias
    }

    # Outras configurações do servidor
}
```

<!--Template: footer() -->
