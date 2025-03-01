import re

class TemplateProcessor:
    def __init__(self, templates_dir):
        # Caminho para o diretório que contém os templates JavaScript
        self.templates_dir = templates_dir

    def process_markdown(self, markdown_content):
        # Substitui as tags de template por chamadas de função JS
        markdown_content = re.sub(r'<!--Template:\s*(\w+)\((.*?)\)\s*-->', self.replace_template_tag, markdown_content)
        return markdown_content

    def replace_template_tag(self, match):
        # Recebe o nome do template e os parâmetros, e retorna a chamada de função JS
        template_name = match.group(1)
        params = match.group(2)
        return f'<script>{template_name}({params})</script>'

    def generate_html_with_scripts(self, html_content):
        # Garante que o script templates.js será importado no HTML
        if '<script src="scripts/templates.js"></script>' not in html_content:
            html_content = html_content.replace('</head>', '<script src="scripts/templates.js"></script>\n</head>')
        return html_content

    def process_html(self, html_content):
        # Substitui as tags de template dentro do conteúdo HTML gerado
        html_content = re.sub(r'<!--Template:\s*(\w+)\((.*?)\)\s*-->', self.replace_template_tag, html_content)
        return html_content
