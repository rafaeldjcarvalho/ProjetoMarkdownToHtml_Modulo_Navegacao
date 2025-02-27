import os

def generate_menu(docs_dir):
    """Gera o menu de navegação para a sidebar, sem arquivos .template.md."""
    menu = ["<nav class='sidebar'><ul>"]

    for root, _, files in os.walk(docs_dir):
        for file in sorted(files):
            if file.endswith(".md") and not file.endswith(".template.md"):  # Ignora templates
                md_path = os.path.relpath(os.path.join(root, file), docs_dir)
                html_path = md_path.replace('.md', '.html')

                # Calcular caminho relativo correto
                depth = md_path.count(os.sep)
                prefix = "../" * depth if depth > 0 else ""

                menu.append(f"<li><a href='{prefix}{html_path}'>{file.replace('.md', '').replace('-', ' ').title()}</a></li>")

    menu.append("</ul></nav>")
    return "\n".join(menu)

def save_menu_to_html(docs_dir, output_dir):
    """Salva o menu gerado em um arquivo HTML reutilizável."""
    menu_md = generate_menu(docs_dir)
    menu_html = "<nav>\n<ul>\n" + menu_md.replace("-", "<li>").replace("\n", "\n</li>\n") + "\n</ul>\n</nav>"
    
    with open(os.path.join(output_dir, "menu.html"), "w", encoding="utf-8") as f:
        f.write(menu_html)

