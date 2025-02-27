import os

class MenuGenerator:
    def generate_menu(self, docs_dir):
        menu = ["<nav class='sidebar'><ul>"]

        for root, _, files in os.walk(docs_dir):
            for file in sorted(files):
                if file.endswith(".md") and not file.endswith(".template.md"):
                    md_path = os.path.relpath(os.path.join(root, file), docs_dir)
                    html_path = md_path.replace('.md', '.html')
                    depth = md_path.count(os.sep)
                    prefix = "../" * depth if depth > 0 else ""
                    menu.append(f"<li><a href='{prefix}{html_path}'>{file.replace('.md', '').replace('-', ' ').title()}</a></li>")

        menu.append("</ul></nav>")
        return "\n".join(menu)
