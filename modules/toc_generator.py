import re

class TableOfContents:
    """
    Classe responsável por gerar a Tabela de Conteúdo (ToC) de arquivos Markdown.
    Identifica os títulos e subtítulos, cria âncoras para navegação e insere a ToC no HTML gerado.
    """

    def __init__(self, toc_depth=3):
        """
        Inicializa a classe com a profundidade máxima dos títulos a serem capturados.

        Args:
            toc_depth (int): Nível máximo de títulos a serem incluídos na ToC (padrão: 3).
        """
        self.toc_depth = toc_depth

    def extract_headings(self, markdown_text):
        """
        Extrai os títulos do Markdown, ignorando blocos de código.
        
        Args:
            markdown_text (str): Conteúdo do arquivo Markdown.

        Returns:
            list: Lista de tuplas com nível, título e âncora de cada seção.
        """
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
        """
        Gera o HTML da Tabela de Conteúdo com links para as seções.

        Args:
            markdown_text (str): Conteúdo do arquivo Markdown.

        Returns:
            str: HTML da ToC.
        """
        toc_entries = self.extract_headings(markdown_text)
        if not toc_entries:
            return ""

        toc_md = "\n\n<nav>\n<ul>\n"
        for level, title, anchor in toc_entries:
            toc_md += f"    <li><a href=\"#{anchor}\">{title}</a></li>\n"
        toc_md += "</ul>\n</nav>\n\n"

        return toc_md
    
    def process_toc(self, markdown_text):
        """
        Processa o Markdown para remover a tag de ToC e substituí-la pelo conteúdo gerado.

        Args:
            markdown_text (str): Conteúdo do arquivo Markdown.

        Returns:
            tuple: Conteúdo do Markdown sem a tag de ToC e o HTML da ToC gerada.
        """
        # Verificar e remover a tag ToC, substituindo pelo conteúdo gerado
        toc_tag_pattern = r"!!!__\s*ToC\s*__!!!"
        if re.search(toc_tag_pattern, markdown_text):
            #print("entrou")
            markdown_text = re.sub(toc_tag_pattern, "", markdown_text)
            toc_html = self.generate_toc(markdown_text)
            return markdown_text, toc_html
        
        return markdown_text, ""
