document.addEventListener('ajax:success', function (e) {
  if (e.target.matches('.card_post_op')) {
    var card = e.target.closest('li.observ_card');
    if (card) card.remove();
  }
});
