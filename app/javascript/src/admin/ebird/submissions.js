document.addEventListener("ajax:beforeSend", function (e) {
  if (!e.target.matches(".ebird-trans")) return;
  e.target.closest(".status-line").insertAdjacentHTML("beforeend", "<img src='/img/loading_small.gif' alt='loading'>");
});

document.addEventListener("ajax:success", function (e) {
  if (!e.target.matches(".ebird-trans")) return;
  e.target.closest(".status-line").innerHTML = e.detail[0].status_line;
});
