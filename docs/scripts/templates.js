function header() {
    const headerDiv = document.createElement('header');

    // Logo
    const logoDiv = document.createElement('div');
    const logoImg = document.createElement('img');
    logoImg.src = `assets/logo-ifs.svg`;
    logoImg.alt = "Logo Instituto Federal";
    logoDiv.appendChild(logoImg);
    headerDiv.appendChild(logoDiv);

    // Título
    const title = document.createElement('h1');
    title.innerText = "Programação Web Avançada";
    headerDiv.appendChild(title);

    // Breadcrumb (opcional)
    const breadcrumb = document.createElement('nav');
    breadcrumb.classList.add('breadcrumb');
    breadcrumb.innerHTML = `
        <a class="breadcrumb-item" href="index.html">Home</a>
        <span class="breadcrumb-item active">Projeto</span>
    `;
    headerDiv.appendChild(breadcrumb);

    // Adicionar header ao corpo da página
    document.body.insertBefore(headerDiv, document.body.firstChild);
}


function footer() {
    const footerDiv = document.createElement('footer');
    footerDiv.innerHTML = `
        <p>&copy; 2025 Instituto Federal de Sergipe - Todos os direitos reservados.</p>
    `;
    document.body.appendChild(footerDiv);
}
