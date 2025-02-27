import os

class BreadcrumbsGenerator:
    def generate_breadcrumbs(self, file_path, docs_dir, root_page):
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
            else:
                breadcrumbs.append(f'<li class="breadcrumb-item active" aria-current="page">{part_name.title()}</li>')

        breadcrumbs.append("</ol></nav>")
        return "\n".join(breadcrumbs)