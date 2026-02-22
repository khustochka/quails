class InstantSearch {
  constructor(container) {
    this.container = container;
    this.dataUrl = container.dataset.url;
    const resultSelector = container.dataset.resultContainer;
    this.resultContainer = (resultSelector && document.querySelector(resultSelector)) ||
                           container.querySelector('.instant_search_results') ||
                           container.nextElementSibling;
    this.requestTimeout = null;
  }

  register() {
    this.container.addEventListener('input', (e) => {
      if (!e.target.matches('.instant_search_input')) return;
      const value = e.target.value;
      if (this.requestTimeout) clearTimeout(this.requestTimeout);
      this.requestTimeout = setTimeout(() => this.sendRequest(value), 500);
    });
  }

  sendRequest(value) {
    fetch(`${this.dataUrl}?term=${encodeURIComponent(value)}&instant_search=1`)
      .then(r => r.text())
      .then(html => { this.resultContainer.innerHTML = html; });
  }
}

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.instant_search_container').forEach(el => {
    new InstantSearch(el).register();
  });
});
