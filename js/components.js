const componentBase = new URL('../components/', document.currentScript.src).href;
const siteRootPath = new URL('../', document.currentScript.src).pathname.replace(/index\.html$/, '').replace(/\/?$/, '/');
const currentPagePath = window.location.pathname.replace(/index\.html$/, '').replace(/\/?$/, '/');
const isRootPage = currentPagePath === siteRootPath;

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

    const pagePaths = {
      about: isRootPage ? './' : '../',
      'open-events': isRootPage ? './open-events/' : '../open-events/',
      activities: isRootPage ? './activities/' : '../activities/',
      'join-us': isRootPage ? './join-us/' : '../join-us/'
    };

    document.querySelectorAll('[data-page-link]').forEach((link) => {
      link.setAttribute('href', pagePaths[link.dataset.pageLink]);
    });
  }
}

Promise.all([
  loadComponent('site-header', `${componentBase}header.html`),
  loadComponent('site-footer', `${componentBase}footer.html`)
]).catch(console.error);