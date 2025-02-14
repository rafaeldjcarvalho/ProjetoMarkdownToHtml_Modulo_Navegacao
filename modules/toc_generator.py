import re
import yaml
import os

def extract_headings(markdown_text, toc_depth=3):
    """Extrai os títulos do Markdown e gera âncoras para o ToC."""
    toc = []
    for line in markdown_text.split("\n"):
        match = re.match(r"^(#{1,6}) (.+)", line)
        if match:
            level = len(match.group(1))  # Quantidade de '#'
            if level <= toc_depth:
                title = match.group(2)
                anchor = title.lower().replace(" ", "-")
                toc.append((level, title, anchor))
    return toc

def generate_toc(markdown_text, toc_depth=3):
    """Gera a estrutura de ToC baseada nos títulos encontrados no Markdown."""
    toc_entries = extract_headings(markdown_text, toc_depth)
    if not toc_entries:
        return ""  # Retorna vazio se não houver títulos

    toc_html = ['<aside class="toc-sidebar"><nav><ul>']
    last_level = 1
    for level, title, anchor in toc_entries:
        indent = "    " * (level - 1)
        toc_html.append(f'{indent}<li><a href="#{anchor}">{title}</a></li>')
    toc_html.append('</ul></nav></aside>')

    return "\n".join(toc_html)

def process_markdown(file_path, config):
    """Processa um arquivo Markdown e insere o ToC corretamente."""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    if "[!__ ToC __!]" in content:
        toc = extract_headings(content, config.get("toc_depth", 3))
        toc_md = generate_toc(toc)
        content = content.replace("[!__ ToC __!]", toc_md)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

def process_all_markdown(docs_dir, config):
    """Processa todos os arquivos Markdown na pasta."""
    for root, _, files in os.walk(docs_dir):
        for file in files:
            if file.endswith(".md"):
                process_markdown(os.path.join(root, file), config)
