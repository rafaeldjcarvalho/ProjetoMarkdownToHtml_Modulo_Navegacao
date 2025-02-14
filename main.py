import os
import yaml
from modules.toc_generator import process_all_markdown as process_toc
from modules.menu_generator import generate_menu
from modules.markdown_converter import process_all_markdown as convert_markdown

def load_config():
    """Carrega configurações do arquivo config.yml"""
    with open("config.yml", "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def process_site():
    """Executa todos os módulos na sequência correta"""
    config = load_config()
    docs_dir = config["docs_dir"]
    output_dir = config["output_dir"]

    # 1. Gerar ToC
    process_toc(docs_dir, config)

    # 2. Criar Menu de Navegação sem arquivos template
    menu_html = generate_menu(docs_dir)

    # 3. Converter Markdown para HTML e inserir o menu abaixo do cabeçalho
    convert_markdown(docs_dir, output_dir, config)

    print("✅ Site gerado com sucesso!")

if __name__ == "__main__":
    process_site()
