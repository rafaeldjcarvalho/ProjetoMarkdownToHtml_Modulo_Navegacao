import os
import shutil
import yaml
from modules.markdown_converter import MarkdownConverter
from modules.menu_generator import MenuGenerator

class SiteGenerator:
    """
    Classe responsável por gerar o site completo a partir de arquivos Markdown.
    Realiza a conversão para HTML, gera o menu, breadcrumbs, ToC e copia recursos como assets, estilos e scripts.
    """

    def __init__(self, config):
        """
        Inicializa a classe com as configurações do site.

        Args:
            config (dict): Configurações do site, incluindo caminhos e opções de navegação.
        """
        self.config = config
        self.menu_generator = MenuGenerator()
        self.converter = MarkdownConverter(config)

    def process_site(self):
        """
        Processa o site inteiro: 
        - Gera o menu
        - Converte os arquivos Markdown para HTML
        - Copia assets, estilos e scripts para o diretório de saída
        """
        docs_dir = self.config["docs_dir"]
        output_dir = self.config["output_dir"]
        
        menu_html = self.menu_generator.generate_menu(docs_dir, output_dir)

        # Capturar a primeira página como raiz
        root_page = None

        for root, _, files in os.walk(docs_dir):
            for file in files:
                if file.endswith(".md") and not root_page:
                    root_page = file  # Define a primeira página como a raiz

                if file.endswith(".md"):
                    input_path = os.path.join(root, file)
                    relative_path = os.path.relpath(input_path, docs_dir)
                    output_path = os.path.join(output_dir, relative_path.replace(".md", ".html"))
                    os.makedirs(os.path.dirname(output_path), exist_ok=True)
                    self.converter.convert_markdown_to_html(input_path, output_path, menu_html, root_page)

        self.copy_assets(docs_dir, output_dir)
        self.copy_styles(docs_dir, output_dir)
        self.copy_scripts(docs_dir, output_dir)

    def copy_assets(self, docs_dir, output_dir):
        """
        Copia a pasta de assets (imagens, ícones, etc.) para o diretório de saída.
        """
        src_assets = os.path.join(docs_dir, "assets")
        dst_assets = os.path.join(output_dir, "assets")
        if os.path.exists(src_assets):
            shutil.copytree(src_assets, dst_assets, dirs_exist_ok=True)

    
    def copy_styles(self, docs_dir, output_dir):
        """
        Copia a pasta de estilos CSS para o diretório de saída.
        """
        src_styles = os.path.join(docs_dir, "styles")
        dst_styles = os.path.join(output_dir, "styles")
        if os.path.exists(src_styles):
            shutil.copytree(src_styles, dst_styles, dirs_exist_ok=True)

    def copy_scripts(self, docs_dir, output_dir):
        """
        Copia a pasta de scripts JavaScript para o diretório de saída.
        """
        src_scripts = os.path.join(docs_dir, "scripts")
        dst_scripts = os.path.join(output_dir, "scripts")
        if os.path.exists(src_scripts):
            shutil.copytree(src_scripts, dst_scripts, dirs_exist_ok=True)


if __name__ == "__main__":
    with open("config.yml", "r", encoding="utf-8") as f:
        config = yaml.safe_load(f)

    site_generator = SiteGenerator(config)
    site_generator.process_site()
    print("✅ Site gerado com sucesso!")
