import re

class TemplateProcessor:
    """
    Classe responsável por processar templates dentro de arquivos Markdown e HTML.
    Permite a substituição de tags específicas por chamadas de funções JavaScript,
    além de garantir a inclusão do arquivo de scripts necessários.
    """

    def __init__(self, templates_dir):
        """
        Inicializa a classe com o caminho para o diretório de templates.

        Args:
            templates_dir (str): Caminho para o diretório que contém os templates JavaScript.
        """
        # Caminho para o diretório que contém os templates JavaScript
        self.templates_dir = templates_dir

    def process_markdown(self, markdown_content):
        """
        Processa o conteúdo Markdown e substitui as tags de template por chamadas de função JS.

        Exemplo:
        <!--Template: alert("Olá") --> → <script>alert("Olá")</script>

        Args:
            markdown_content (str): Conteúdo Markdown bruto.
        
        Returns:
            str: Conteúdo Markdown com as tags de template processadas.
        """
        # Substitui as tags de template por chamadas de função JS
        markdown_content = re.sub(r'<!--Template:\s*(\w+)\((.*?)\)\s*-->', self.replace_template_tag, markdown_content)
        return markdown_content

    def replace_template_tag(self, match):
        """
        Substitui a tag de template por uma chamada de função JavaScript.

        Args:
            match (re.Match): Objeto de correspondência da expressão regular.
        
        Returns:
            str: Script HTML com a função JavaScript.
        """
        # Recebe o nome do template e os parâmetros, e retorna a chamada de função JS
        template_name = match.group(1)
        params = match.group(2)
        return f'<script>{template_name}({params})</script>'

    def generate_html_with_scripts(self, html_content):
        """
        Garante que o arquivo templates.js seja importado no HTML final.

        Args:
            html_content (str): Conteúdo HTML gerado.
        
        Returns:
            str: Conteúdo HTML com a inclusão do script templates.js.
        """
        # Garante que o script templates.js será importado no HTML
        if '<script src="scripts/templates.js"></script>' not in html_content:
            html_content = html_content.replace('</head>', '<script src="scripts/templates.js"></script>\n</head>')
        return html_content

    def process_html(self, html_content):
        """
        Processa o conteúdo HTML para substituir as tags de template restantes.

        Args:
            html_content (str): Conteúdo HTML gerado.
        
        Returns:
            str: Conteúdo HTML com as tags de template processadas.
        """
        # Substitui as tags de template dentro do conteúdo HTML gerado
        html_content = re.sub(r'<!--Template:\s*(\w+)\((.*?)\)\s*-->', self.replace_template_tag, html_content)
        return html_content
