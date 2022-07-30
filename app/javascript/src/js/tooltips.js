import tippy from 'tippy.js';
import 'tippy.js/dist/tippy.css';

// Using tippy because bootstrap tooltip is unreliable

tippy.setDefaultProps(
  {
    content: (reference) => reference.getAttribute('title'),
  }
)

document.addEventListener('DOMContentLoaded', function () {
  const tpTriggers = document.querySelectorAll("[data-tooltip]"),
    lifelistTriggers = document.querySelectorAll(".lifer-locus-icon");

  const allTriggers = [...tpTriggers].concat([...lifelistTriggers])

  allTriggers.forEach(el => {
    tippy(el)
    el.removeAttribute("title")
  })
})
