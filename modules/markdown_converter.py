import os
import re
import subprocess
from modules.breadcrumbs_generator import BreadcrumbsGenerator
from modules.toc_generator import TableOfContents

class MarkdownConverter:
    def __init__(self, config):
        self.config = config
        self.toc_generator = TableOfContents(config.get("toc_depth", 3))
        self.breadcrumb_generator = BreadcrumbsGenerator()

    def fix_internal_links(self, content):
        return re.sub(r'href="([^"]+)\.md(#.*?)?"', r'href="\1.html\2"', content)

    def convert_markdown_to_html(self, input_file, output_file, menu_html, root_page):
        with open(input_file, "r", encoding="utf-8") as f:
            md_content = f.read()

        toc_pattern = re.compile(r'(<div class="bloco-my-1">.*?!!!__\s*ToC\s*__!!!.*?</div>)', re.DOTALL)
        toc_html = ""
        toc_match = toc_pattern.search(md_content)
        if toc_match:
            toc_html = self.toc_generator.generate_toc(md_content)
            md_content = toc_pattern.sub(toc_html, md_content)

        temp_md_file = input_file + "_temp.md"
        with open(temp_md_file, "w", encoding="utf-8") as f:
            f.write(md_content)

        pandoc_cmd = [
            self.config["pandoc_path"],
            temp_md_file,
            "-o", output_file,
            "--template", self.config["template_path"],
            "--metadata", f'title="{os.path.basename(input_file)}"'
        ]
        subprocess.run(pandoc_cmd, check=True)

        os.remove(temp_md_file)

        with open(output_file, "r", encoding="utf-8") as f:
            content = f.read()

        content = self.fix_internal_links(content)
        breadcrumbs_html = self.breadcrumb_generator.generate_breadcrumbs(input_file, self.config["docs_dir"], root_page)
        content = content.replace("<!-- MENU -->", menu_html)
        content = content.replace("<main class=\"markdown-body\">", f"<main class=\"markdown-body\">\n{breadcrumbs_html}")

        # Adicionar o link para o CSS
        content = content.replace("</head>", "<link rel='stylesheet' href='styles/style_navigation.css'>\n</head>")

        if toc_html:
            content = content.replace("<!-- ToC será inserido aqui -->", f"{toc_html}")

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(content)