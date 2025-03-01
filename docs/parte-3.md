--id: parte-3
--titulo: Parte 3

<!--Template: header() -->

<h2 class="ca-pg-title">Parte 3: Uma Nova Proposta de Entrega</h2>

## 3.1. Módulos do Projeto (sugestão)

Para facilitar a integração entre os módulos, cada módulo pode ser um programa (um .exe) independente (ou vários .exe se preferir).

- Cada módulo possui sua função no sistema. P.ex. (a) um programa para ler o cabeçalho markdown do arquivo, para obter p.ex. o título da página, autor, data, data de modificação, termos de busca para o SEO etc. (b) outro programa para gerar o ToC (sumário) das páginas web. (c) outro para verificar a disponibilidade das urls ...
- Os programa devem ser CLI (*Command Line Interface*), para rodar na linha de comando (cmd). Ele possui argumentos de entrada e gera uma saída (em geral, arquivos).

### Módulo 1: Estrutura e Navegação

- [Navegação]{.d-2}: Geração automática de menus, painéis de navegação, breadcrumbs (trilha de navegação), ToC (Table of Contents, tabela de conteúdo) ... para facilitar a navegação no site.

- [Suporte a Templates]{.d-2}: Para facilitar a reutilização de componentes como cabeçalhos, rodapés e outros elementos padronizados. Similar ao que o framework React faz. P.ex.

    ```js
    const Footer = ({ siteName, year }) => (
        <footer>
            <p>© {year} {siteName}. Todos os direitos reservados.</p>
        </footer>
    );

    const App = () => (
        <div>
            <Header />
            ...
            <Footer siteName="Meu Site" year={2024} /> // Exemplo de uso
        </div>
    );
    ```

--h:thin----------------------------------------------------------------------------------

### Módulo 2: Aparência

- [Customização Visual]{.d-2}: Implementação de um sistema temas para permitir a personalização da aparência do site, adaptando-se às preferências do usuário e identidade visual desejada.
    - [Temas pré-definidos]{.d-3}: Oferecer uma gama de temas para o usuário escolher, tais como github, github-dark, vscode, vscode-dark, material, dracula, dentre outros.
    - [Customização do tema, com suporte a SCSS]{.d-3}: Permitir que o usuário customize facilmente o tema corrente usando SCSS.
    - [Alternância entre os Modos Light / Dark]{.d-3}
        - Com apenas um clique o usuário pode definir o modo de exibição light (claro) ou dark (escuro).
        - O navegador deve lembrar o modo de exibição que o usuário escolheu. Então mesmo que o usuário feche o navegador, quando ele voltar para o site, o modo de exibi
        cão deve ser o mesmo usado anteriormente. Sugestão: use LocalStorage.

- [Realce de Sintaxe de Código]{.d-2} (sintax highlight): Para melhorar a legibilidade e compreensão do código, utilizando diversas linguagens de programação.

- [Copiar Código]{.d-2}: Funcionalidade copiar código com um clique utilizando JavaScript.

- [Modo Leitura]{.d-2}: Com apenas um clique o usuário pode entrar no modo de leitura, onde apenas o conteúdo do `<main>` é exibido em tela, os demais componentes são ocultados.

- [Tempo de Leitura]{.d-2}: Logo abaixo o título da página, exibir o tempo de leitura da página, por exemplo: `Tempo de leitura: 30 min`. Em média uma pessoa lê 200..250 palavras/minuto.

--h:thin----------------------------------------------------------------------------------

### Módulo 3: Busca e SEO

- [Busca Local]{.d-2}: Mecanismos de indexação para permitir a busca de conteúdo dentro do site.
    - Permitir filtrar páginas por data de criação, atualização, categoria e/ou palavras-chaves. Ambos, devem estar definidos nos metadados do Markdown.

- [Otimização para Mecanismos de Busca (SEO)]{.d-2}: Incorporação de técnicas de SEO, como metadados, URLs amigáveis, visando melhorar o posicionamento do site em mecanismos de busca.

- [Geração de Feed RSS]{.d-2}: Criação automática de feeds RSS para facilitar a disseminação de atualizações do site. O feed RSS permite que os leitores do site recebam notificações e acompanhem as novidades de forma prática, sem precisar visitar o site frequentemente.

--h:thin----------------------------------------------------------------------------------

### Módulo 4: Otimização do Site

- [Otimização de Recursos]{.d-2}:
    - Minificação de arquivos CSS, JavaScript e HTML.
    - Otimização de imagens para reduzir o tempo de carregamento das páginas.

--h:thin----------------------------------------------------------------------------------

### Não constitui uma tarefa

- [Conversão Markdown para HTML]{.d-2}: Para criação do website.

- [Páginas Responsivas (NÃO é preciso)]{.d-2}: Por simplificação, o site NÃO precisa se adequar a diferentes tamanhos de telas.

--h:thin----------------------------------------------------------------------------------

## 3.2. Funcionalidades Adicionais

1. [Controle de Acesso]{.d-2}: Restringir o acesso ao site apenas aos usuários autorizados.

1. [Integração com Google Analytics]{.d-2}: Monitorar métricas de acesso ao site através de ferramentas de análise.

1. [Sistema de Comentários]{.d-2}: Permitir que os usuários deixem comentários nas páginas do site.

1. [Integração com Redes Sociais]{.d-2}: Facilitar o compartilhamento de conteúdo e a presença do site em redes sociais.

1. [Exportar para a Página]{.d-2}: Disponibilizar opções de download do conteúdo da página em formatos como Markdown, PDF e DOCX.

1. [Suporte a Multilínguas]{.d-2}: (a) Apresentar o site em diferentes idiomas. (b) Oferecer opções de tradução, como os tradutores fornecidos pelo Google.

<!--Template: footer() -->
