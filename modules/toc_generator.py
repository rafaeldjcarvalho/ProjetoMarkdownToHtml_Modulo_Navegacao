import re

class TableOfContents:
    def __init__(self, toc_depth=3):
        self.toc_depth = toc_depth

    def extract_headings(self, markdown_text):
        toc = []
        inside_code_block = False

        for line in markdown_text.split("\n"):
            if line.strip().startswith("```"):
                inside_code_block = not inside_code_block
            
            if inside_code_block:
                continue

            match = re.match(r"^(#{1,6}) (.+)", line)
            if match:
                level = len(match.group(1))
                if level <= self.toc_depth:
                    title = match.group(2)

                    # Remover numeração da seção (se houver)
                    title_without_numbering = re.sub(r"^\d+(\.\d+)*\.\s*", "", title)

                    # Criar âncora sem numeração e com espaço no lugar de hífen
                    anchor = title_without_numbering.lower().replace(" ", "-")

                    # Remover parênteses, % e vírgulas
                    anchor = re.sub(r"[()%\,]", "", anchor)

                    toc.append((level, title, anchor))

        return toc

    def generate_toc(self, markdown_text):
        toc_entries = self.extract_headings(markdown_text)
        if not toc_entries:
            return ""

        toc_md = "\n\n<nav>\n<ul>\n"
        for level, title, anchor in toc_entries:
            toc_md += f"    <li><a href=\"#{anchor}\">{title}</a></li>\n"
        toc_md += "</ul>\n</nav>\n\n"

        return toc_md
