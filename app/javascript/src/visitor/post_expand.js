class PostExpander {
  constructor(el) {
    const linkText = el.getAttribute("data-expand-link");
    const link = document.createElement("span");
    link.textContent = linkText;
    link.classList.add("pseudolink");
    link.classList.add("lang_expand_link");
    const pInsideEl = el.querySelector("p");
    pInsideEl.appendChild(link);
    this.link = link;
    this.toExpand = el.parentElement.querySelectorAll(".other_lang_expand");
    this.toExpand.forEach(box => { box.style.display = "none" })
  }

register() {
    this.link.addEventListener("click", () => {
      this.toExpand.forEach(box => { box.style.display = "block" });
      this.link.style.display = "none";
    });
  }
}

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll(".diff_lang_expand_notice[data-expand-link]").forEach(function (el) {
    const postExpander = new PostExpander(el);
    postExpander.register();
  });
})
