$(function () {

  // reload search results after attach/detach

  $(document).on('ajax:beforeSend', '.card_post_op', function () {
    $(this).closest(".observ_card").addClass('loading');
  });

  $(document).on('ajax:success', '.card_post_op', function () {
    if (typeof(reloadCardsSearch) == "function") {
      reloadCardsSearch();
    }
  });
});
