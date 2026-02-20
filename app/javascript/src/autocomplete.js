export default class Autocomplete {
  // options:
  //   source(term) -> Promise<Array<{label, value, ...}>>
  //   renderItem(li, item) -> void   — populate a <li> for a result item
  //   renderFallback(li) -> void     — populate a <li> for the fallback item (optional)
  //   onSelect(item) -> void         — called when a result item is selected
  //   onFallback() -> void           — called when the fallback item is selected (optional)
  //   minLength: int (default 0)     — minimum chars before fetching
  //   debounce: int (default 200)    — ms to wait after typing before fetching
  //   autoFocus: bool (default false) — automatically highlight first item after each fetch
  constructor(input, options) {
    this.input = input;
    this.options = Object.assign({ minLength: 0, debounce: 200, autoFocus: false }, options);
    this.items = [];
    this.activeIndex = -1;
    this.currentTerm = null;

    this._buildDropdown();
    this._bindEvents();
  }

  _buildDropdown() {
    this.dropdown = document.createElement("ul");
    this.dropdown.className = "ac-dropdown";
    this.dropdown.style.display = "none";

    document.body.appendChild(this.dropdown);

    Object.assign(this.dropdown.style, {
      position: "absolute",
      zIndex: "1000",
      listStyle: "none",
      margin: "0",
      padding: "0",
      backgroundColor: "white",
      border: "1px solid #ccc",
    });
  }

  _positionDropdown() {
    const rect = this.input.getBoundingClientRect();
    Object.assign(this.dropdown.style, {
      top: (rect.bottom + window.scrollY) + "px",
      left: (rect.left + window.scrollX) + "px",
      width: rect.width + "px",
    });
  }

  _bindEvents() {
    this.input.addEventListener("focus", () => {
      if (this.input.value && this.input.value.length >= this.options.minLength) {
        this._onInput();
      }
    });
    this.input.addEventListener("input", () => {
      clearTimeout(this._debounceTimer);
      const term = this.input.value;
      if (!term || term.length < this.options.minLength) {
        this._close();
        return;
      }
      this._debounceTimer = setTimeout(() => this._onInput(), this.options.debounce);
    });
    this.input.addEventListener("blur", () => setTimeout(() => this._close(), 150));
    this.input.addEventListener("keydown", (e) => this._onKeydown(e));
  }

  _onInput() {
    const term = this.input.value;
    if (!term || term.length < this.options.minLength) {
      this._close();
      return;
    }
    this.currentTerm = term;
    this.options.source(term).then(items => {
      if (term !== this.currentTerm) return;
      this.items = items;
      this._render();
      this._open();
    });
  }

  _onKeydown(e) {
    if (this.dropdown.style.display === "none") return;
    const total = this.dropdown.children.length;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      this._setActive((this.activeIndex + 1) % total);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this._setActive((this.activeIndex - 1 + total) % total);
    } else if (e.key === "Enter" || e.key === "Tab") {
      if (this.activeIndex >= 0) {
        e.preventDefault();
        this.dropdown.children[this.activeIndex].click();
      }
    } else if (e.key === "Escape") {
      this._close();
    }
  }

  _render() {
    this.dropdown.innerHTML = "";
    this.activeIndex = -1;

    this.items.forEach((item, i) => {
      const li = document.createElement("li");
      this.options.renderItem(li, item);
      li.addEventListener("mouseenter", () => this._setActive(i));
      li.addEventListener("click", () => this.options.onSelect(item));
      this.dropdown.appendChild(li);
    });

    if (this.options.autoFocus && this.items.length > 0) this._setActive(0);

    if (this.options.renderFallback) {
      const li = document.createElement("li");
      li.className = "fallback_item";
      this.options.renderFallback(li);
      const idx = this.dropdown.children.length;
      li.addEventListener("mouseenter", () => this._setActive(idx));
      li.addEventListener("click", () => { this._close(); this.options.onFallback?.(); });
      this.dropdown.appendChild(li);
    }

  }

  _setActive(index) {
    Array.from(this.dropdown.children).forEach((li, i) => {
      li.querySelector("a")?.classList.toggle("active", i === index);
    });
    this.activeIndex = index;
  }

  _open() {
    if (this.dropdown.children.length > 0) {
      this._positionDropdown();
      this.dropdown.style.display = "block";
    }
  }

  _close() {
    this.dropdown.style.display = "none";
    this.activeIndex = -1;
    this.currentTerm = null;
  }
}
