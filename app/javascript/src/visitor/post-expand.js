function initPostExpander(el) {
  const link = document.createElement("span");
  link.textContent = el.getAttribute("data-expand-link");
  link.classList.add("pseudolink", "lang_expand_link");
  el.querySelector("p").appendChild(link);

  const toExpand = el.parentElement.querySelectorAll(".other_lang_expand");
  toExpand.forEach(box => { box.style.display = "none" });

  link.addEventListener("click", () => {
    toExpand.forEach(box => { box.style.display = "block" });
    link.style.display = "none";
  });
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".diff_lang_expand_notice[data-expand-link]").forEach(initPostExpander);
});
