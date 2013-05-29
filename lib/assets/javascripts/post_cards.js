$(function () {

  // reload search results after attach/detach

  $(".cards_list").on('ajax:beforeSend', '.card_post_op', function () {
    $(this).closest(".observ_card").addClass('loading');
  });

  $(".cards_list").on('ajax:success', '.card_post_op', function () {
    if (typeof(reloadCardsSearch) == "function") {
      reloadCardsSearch();
    }
  });


});
