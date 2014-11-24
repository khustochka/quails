//= require cards_search_remote
//= require post_cards


// Lj post
$(function () {
  var lj_post_form = $('form#lj_post');
  lj_post_form.data('remote', true);
  lj_post_form.attr('action', lj_post_form.attr('action') + '.json');

  lj_post_form.bind('ajax:beforeSend', function () {
    $("li#lj_url_li").append("<img src='/img/loading_small.gif' id='spinner'>");
  });

  lj_post_form.bind("ajax:error", function (e, xhr) {
    $('#spinner').remove();
    alert($.parseJSON(xhr.responseText).alert);
  });

  lj_post_form.bind("ajax:success", function (e, data) {
    var url = data.url;
    $("li#lj_url_li").html($("<a>", {text: url, href: url}));
  });
});

function reloadCardsSearch() {
  $('form.search').submit();
}
