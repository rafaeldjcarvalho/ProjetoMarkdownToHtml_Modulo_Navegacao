import os
import re
import subprocess
import shutil
from modules.menu_generator import generate_menu
from modules.breadcrumbs_generator import generate_breadcrumbs
from modules.toc_generator import generate_toc

def fix_internal_links(content):
    """Corrige links internos para seções, convertendo .md#section para .html#section"""
    return re.sub(r'href="([^"]+)\.md(#.*?)?"', r'href="\1.html\2"', content)

def convert_markdown_to_html(input_file, output_file, config, menu_html):
    """Converte Markdown para HTML, insere menu, breadcrumbs e ToC corretamente."""
    with open(input_file, "r", encoding="utf-8") as f:
        md_content = f.read()

    # Expressão regular para capturar a tag !!!__ ToC __!!! dentro de <div>
    toc_pattern = re.compile(r'(<div class="bloco-my-1">.*?!!!__\s*ToC\s*__!!!.*?</div>)', re.DOTALL)

    toc_html = ""
    toc_match = toc_pattern.search(md_content)
    if toc_match:
        toc_html = generate_toc(md_content, config["toc_depth"])  # Gera o ToC
        md_content = toc_pattern.sub(toc_html, md_content)  # Substitui a marcação pelo ToC

    # Criar um arquivo temporário para o Markdown modificado
    temp_md_file = input_file + "_temp.md"
    with open(temp_md_file, "w", encoding="utf-8") as f:
        f.write(md_content)

    # Converter o Markdown para HTML usando Pandoc
    pandoc_cmd = [
        config["pandoc_path"],
        temp_md_file,
        "-o", output_file,
        "--template", config["template_path"],
        "--metadata", f'title="{os.path.basename(input_file)}"'
    ]
    subprocess.run(pandoc_cmd, check=True)

    # Remover o arquivo temporário
    os.remove(temp_md_file)

    # Modificar o HTML gerado para inserir ToC corretamente na sidebar
    with open(output_file, "r", encoding="utf-8") as f:
        content = f.read()

    # Corrigir links internos com seções
    content = re.sub(r'href="([^"]+)\.md(#.*?)?"', r'href="\1.html\2"', content)

    # Gerar os breadcrumbs para a página
    breadcrumbs_html = generate_breadcrumbs(input_file, config["docs_dir"])

    # Inserir o menu na sidebar esquerda
    content = content.replace("<!-- MENU -->", menu_html)

    # Se for index.html, remover os breadcrumbs
    if "index.html" in output_file:
        breadcrumbs_html = ""

    # Inserir breadcrumbs logo após a abertura da tag <main>
    content = content.replace("<main class=\"markdown-body\">", f"<main class=\"markdown-body\">\n{breadcrumbs_html}")

    # Inserir ToC dentro da sidebar direita também
    if toc_html:
        content = content.replace("<!-- ToC será inserido aqui -->", f"{toc_html}")

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(content)

def process_all_markdown(docs_dir, output_dir, config):
    """Converte todos os arquivos Markdown em HTML e insere o menu."""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Gerar o menu antes da conversão
    menu_html = generate_menu(docs_dir)

    for root, _, files in os.walk(docs_dir):
        for file in files:
            if file.endswith(".md"):
                input_path = os.path.join(root, file)
                relative_path = os.path.relpath(input_path, docs_dir)
                output_path = os.path.join(output_dir, relative_path.replace(".md", ".html"))
                os.makedirs(os.path.dirname(output_path), exist_ok=True)

                # Passar o menu para ser inserido no HTML
                convert_markdown_to_html(input_path, output_path, config, menu_html)

    # Copiar a pasta assets para dist/
    copy_assets(docs_dir, output_dir)


def copy_assets(docs_dir, output_dir):
    """Copia a pasta assets para a pasta de saída, preservando a estrutura."""
    src_assets = os.path.join(docs_dir, "assets")
    dst_assets = os.path.join(output_dir, "assets")

    if os.path.exists(src_assets):
        shutil.copytree(src_assets, dst_assets, dirs_exist_ok=True)
        print(f"📂 Assets copiados para {dst_assets}")
    else:
        print("⚠️ Pasta 'assets' não encontrada em docs/. Pulando cópia.")