import os

def generate_breadcrumbs(file_path, docs_dir):
    """Gera os breadcrumbs completos com base na hierarquia do site."""
    rel_path = os.path.relpath(file_path, docs_dir)  # Caminho relativo dentro de docs/
    parts = rel_path.replace("\\", "/").split("/")  # Divide os diretórios

    breadcrumbs = ['<nav aria-label="breadcrumb"><ol class="breadcrumb">']
    path_accumulated = ""
    
    # Adicionar o primeiro item (Index) sempre
    breadcrumbs.append('<li class="breadcrumb-item"><a href="index.html">Index</a></li>')

    for i, part in enumerate(parts):
        if part.endswith(".md"):  # Último item (página atual)
            part_name = part.replace(".md", "")
        else:
            part_name = part  # Diretório

        path_accumulated = os.path.join(path_accumulated, part_name).replace("\\", "/")

        if i < len(parts) - 1:  # Diretórios intermediários (com link)
            breadcrumbs.append(f'<li class="breadcrumb-item"><a href="{path_accumulated}.html">{part_name.title()}</a></li>')
        else:  # Último item (página atual, sem link)
            breadcrumbs.append(f'<li class="breadcrumb-item active" aria-current="page">{part_name.title()}</li>')

    breadcrumbs.append("</ol></nav>")

    return "\n".join(breadcrumbs)
