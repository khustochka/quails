class PostExpander {
  constructor(el) {
    let linkText = el.getAttribute("data-expand-link");
    let link = document.createElement("span");
    link.textContent = linkText;
    link.classList.add("pseudolink");
    link.classList.add("lang_expand_link");
    let pInsideEl = el.querySelector("p");
    pInsideEl.appendChild(link);
    this.link = link;
    this.toExpand = el.parentElement.querySelectorAll(".other_lang_expand");
    this.toExpand.forEach(box => { box.style.display = "none" })
  }

register() {
    const _this = this;
    this.link.addEventListener("click", function () {
      _this.toExpand.forEach(box => { box.style.display = "block" });
      _this.link.style.display = "none";
    });
  }
}

document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll(".diff_lang_expand_notice[data-expand-link]").forEach(function (el) {
    const postExpander = new PostExpander(el);
    postExpander.register();
  });
})
