//= require cards_search_remote
//= require post_cards


// Lj post
$(function () {
  var lj_post_form = $('form#lj_post');
  lj_post_form.data('remote', true);
  lj_post_form.attr('action', lj_post_form.attr('action') + '.json');

  lj_post_form[0].addEventListener('ajax:beforeSend', function () {
    $("li#lj_url_li").append("<img src='/img/loading_small.gif' id='spinner'>");
  });

  lj_post_form[0].addEventListener("ajax:error", function (e) {
    var xhr = e.detail[0];
    $('#spinner').remove();
    alert(JSON.parse(xhr.responseText).alert);
  });

  lj_post_form[0].addEventListener("ajax:success", function (e) {
    var url = e.detail[0].url;
    $("li#lj_url_li").html($("<a>", {text: url, href: url}));
  });
});

function reloadCardsSearch() {
  var form = document.querySelector('form.search');
  if (form) form.requestSubmit();
}
