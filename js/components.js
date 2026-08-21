async function loadComponent(id, path) {
  const response = await fetch(path);

  if (!response.ok) {
    throw new Error(`Could not load ${path}: ${response.status}`);
  }

  document.getElementById(id).innerHTML = await response.text();
}

Promise.all([
  loadComponent("site-header", "/BIWC/components/header.html"),
  loadComponent("site-footer", "/BIWC/components/footer.html")
]).catch(console.error);