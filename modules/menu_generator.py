import os

class MenuGenerator:
    """
    Classe responsável por gerar o menu de navegação para o site.
    O menu é construído com base na estrutura de arquivos Markdown, 
    convertendo-os para links HTML organizados hierarquicamente.
    """
     
    def generate_menu(self, docs_dir, dist_dir):
        """
        Gera o menu de navegação com base nos arquivos Markdown encontrados.
        
        Args:
            docs_dir (str): Caminho para o diretório contendo os arquivos Markdown.
            dist_dir (str): Caminho para o diretório de saída (HTML).
        
        Returns:
            str: HTML do menu gerado.
        """
        menu = ["<nav class='sidebar'><ul>"]

        # Caminho base para os arquivos HTML
        dist_path_base = os.path.relpath(dist_dir, docs_dir)

        for root, _, files in os.walk(docs_dir):
            for file in sorted(files):
                if file.endswith(".md") and not file.endswith(".template.md"):
                    md_path = os.path.relpath(os.path.join(root, file), docs_dir)  # Caminho relativo dentro de docs_dir
                    html_path = md_path.replace('.md', '.html')  # Substitui a extensão .md por .html
                    
                    # Ajusta o prefixo para refletir a estrutura correta de dist
                    depth = md_path.count(os.sep)
                    prefix = "../" * (depth - 1) if depth > 1 else ""  # Corrige a profundidade do caminho
                    
                    # Gera o caminho correto a partir de dist_dir
                    html_path = os.path.join(dist_path_base, html_path)  # Gera o caminho correto a partir de dist_dir
                    html_path = os.path.normpath(html_path)  # Normaliza o caminho para evitar duplicação de diretórios

                    menu.append(f"<li><a href='{html_path}'>{file.replace('.md', '').replace('-', ' ').title()}</a></li>")

        menu.append("</ul></nav>")
        return "\n".join(menu)
