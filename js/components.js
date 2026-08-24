const isRootPage = window.location.pathname.replace(/\/+$/, '').split('/').filter(Boolean).length <= 1;
const componentBase = new URL('../components/', document.currentScript.src).href;

async function loadComponent(id, path) {
  const response = await fetch(path);

  if (!response.ok) {
    throw new Error(`Could not load ${path}: ${response.status}`);
  }

  const html = await response.text();
  document.getElementById(id).innerHTML = html;

  if (id === 'site-header') {
    const homeLink = document.querySelector('[data-home-link]');
    if (homeLink) {
      homeLink.setAttribute('href', isRootPage ? './' : '../');
    }
  }
}

Promise.all([
  loadComponent('site-header', `${componentBase}header.html`),
  loadComponent('site-footer', `${componentBase}footer.html`)
]).catch(console.error);