document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('tree');
  if (!el) return;
  const id = el.getAttribute('data-root');
  fetch(`/api/tree/${id}`)
    .then(r => r.json())
    .then(data => {
      el.innerHTML = '';
      const root = document.createElement('div');
      root.innerHTML = `<div class="fw-bold">${data.name}</div>`;
      el.appendChild(root);
      const ul = document.createElement('ul');
      data.children.forEach(c => {
        const li = document.createElement('li');
        li.innerHTML = `<a href="/People/Details/${c.id}">${c.name}</a>`;
        ul.appendChild(li);
      });
      el.appendChild(ul);
    })
    .catch(() => { el.innerHTML = '<span class="text-muted">Không có dữ liệu cây.</span>'; });
});
