# Gerador de Sites Estáticos a partir de Markdown

Este projeto é um gerador de sites estáticos que converte arquivos Markdown em páginas HTML navegáveis, com funcionalidades avançadas como menus, breadcrumbs, Tabela de Conteúdo (ToC) e suporte a templates. Ideal para documentação técnica, blogs ou sites de conteúdo.

## 📘 Funcionalidades

- **Conversão de Markdown para HTML:** Utiliza o Pandoc para transformar arquivos `.md` em `.html`, preservando a estrutura do documento.
- **Menu de Navegação Automático:** Gera um menu lateral com links para todas as páginas do site.
- **Breadcrumbs:** Mostra o caminho de navegação atual, com base nos metadados ou na estrutura de pastas.
- **Tabela de Conteúdo (ToC):** Gera uma lista de links para as seções do documento, baseada nos títulos do Markdown.
- **Templates Dinâmicos:** Permite usar templates com JavaScript para componentes reutilizáveis.
- **Cópia de Recursos:** Copia automaticamente pastas de assets, estilos e scripts para o diretório de saída.

## 🛠️ Bibliotecas Necessárias

- Python 3.10+
- `PyYAML` (para ler configurações)
- `Pandoc` (para conversão Markdown → HTML)

Instalação das dependências:
```bash
pip install pyyaml
```

Instale o Pandoc:
- [Download Pandoc](https://pandoc.org/installing.html)

## ⚙️ Como Utilizar

1. **Estruture suas pastas:**
```
./docs
├── index.md
├── parte-1.md
├── assets/
├── styles/
└── scripts/
```

2. **Crie um arquivo de configuração (`config.yml`):**
```yaml
docs_dir: ./docs
output_dir: ./dist
pandoc_path: ./pandoc.exe
template_path: ./templates/template.html
toc_depth: 3
```

3. **Adicione metadados nos arquivos Markdown:**
```markdown
--id: index
--titulo: Página Inicial
--breadcrumbs: index
```

4. **Execute o programa:**
```bash
python site_generator.py
```

O site será gerado na pasta `./dist` com a mesma estrutura da pasta de origem!

## 🏗️ Estrutura das Classes

- **MarkdownConverter:** Converte arquivos Markdown para HTML, insere ToC e breadcrumbs.
- **MenuGenerator:** Gera o menu de navegação com base nos arquivos Markdown.
- **BreadcrumbsGenerator:** Cria a trilha de navegação com base nos metadados ou estrutura de diretórios.
- **TableOfContents:** Extrai títulos e gera a ToC com links para as seções.
- **TemplateProcessor:** Processa templates JavaScript dentro dos arquivos Markdown.
- **SiteGenerator:** Orquestra o processo completo, organizando a conversão e cópia de recursos.

## 🚀 Resultado

Após a execução, você terá um site completo com:
- Páginas HTML organizadas
- Navegação lateral e breadcrumbs funcionais
- Tabela de Conteúdo para fácil navegação
- Recursos (imagens, CSS, JS) copiados automaticamente

---

Com isso, você terá uma ferramenta poderosa para transformar seus documentos Markdown em sites completos e profissionais!🚀✨

