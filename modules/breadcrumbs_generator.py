import os
import re

class BreadcrumbsGenerator:
    def parse_metadata(self, markdown_content):
        # Capturar as variáveis do topo do documento
        id_match = re.search(r'--id:\s*(.+)', markdown_content)
        title_match = re.search(r'--titulo:\s*(.+)', markdown_content)
        breadcrumbs_match = re.search(r'--breadcrumbs:\s*(.+)', markdown_content)

        return {
            "id": id_match.group(1).strip() if id_match else None,
            "title": title_match.group(1).strip() if title_match else None,
            "breadcrumbs": breadcrumbs_match.group(1).strip() if breadcrumbs_match else None
        }

    def find_page_by_id(self, page_id, docs_dir):
        # Buscar o arquivo pelo ID e pegar o título
        for root, _, files in os.walk(docs_dir):
            for file in files:
                file_path = os.path.join(root, file)
                if file.endswith(".md"):
                    with open(file_path, encoding="utf-8") as f:
                        content = f.read()
                        if f"--id: {page_id}" in content:
                            title_match = re.search(r'--titulo:\s*(.+)', content)
                            title = title_match.group(1).strip() if title_match else page_id
                            return file_path, title
        return None, page_id

    def generate_breadcrumbs(self, file_path, docs_dir, root_page):
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                md_content = file.read()
        except FileNotFoundError:
            return ""

        metadata = self.parse_metadata(md_content)
        
        breadcrumbs = ['<nav aria-label="breadcrumb"><ol class="breadcrumb">']
        
        if metadata["breadcrumbs"]:
            breadcrumb_ids = [crumb.strip() for crumb in metadata["breadcrumbs"].split('>')]

            breadcrumb_titles = set()  # Para garantir que não haja duplicação de títulos
            for i, crumb_id in enumerate(breadcrumb_ids):
                page_path, title = self.find_page_by_id(crumb_id, docs_dir)
                
                if page_path:
                    html_path = os.path.relpath(page_path, docs_dir).replace('.md', '.html')
                    # Adicionar o título correto ao invés do ID, mas verificar duplicação
                    if title not in breadcrumb_titles:
                        breadcrumb_titles.add(title)
                        if i < len(breadcrumb_ids) - 1:
                            breadcrumbs.append(f'<li class="breadcrumb-item"><a href="{html_path}">{title}</a></li>')

        else:
            # Fallback para a estrutura de diretórios
            rel_path = os.path.relpath(file_path, docs_dir)
            parts = rel_path.replace("\\", "/").split("/")
            
            breadcrumbs = ['<nav aria-label="breadcrumb"><ol class="breadcrumb">']
            path_accumulated = ""
            
            root_name = os.path.splitext(os.path.basename(root_page))[0].title()
            
            # Só adiciona a página raiz se não estiver nela
            if not rel_path.endswith(root_page):
                breadcrumbs.append(f'<li class="breadcrumb-item"><a href="{root_name}.html">{root_name}</a></li>')

            for i, part in enumerate(parts):
                if part.endswith(".md"):
                    part_name = part.replace(".md", "")
                else:
                    part_name = part

                path_accumulated = os.path.join(path_accumulated, part_name).replace("\\", "/")

                if i < len(parts) - 1:
                    breadcrumbs.append(f'<li class="breadcrumb-item"><a href="{path_accumulated}.html">{part_name.title()}</a></li>')

        # Adicionar o título do próprio documento, caso não esteja presente nos breadcrumbs
        if metadata["title"] and metadata["title"] not in [crumb.split(">")[-1].strip() for crumb in breadcrumbs]:
            breadcrumbs.append(f'<li class="breadcrumb-item active" aria-current="page">{metadata["title"]}</li>')
        
        breadcrumbs.append("</ol></nav>")
        return "\n".join(breadcrumbs)
