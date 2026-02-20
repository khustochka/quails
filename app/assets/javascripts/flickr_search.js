$(function () {
  $('#spinner').hide();

  var flickrForm = document.querySelector('form[action="/flickr/photos/search"]');

  flickrForm.addEventListener("ajax:send", function () {
    $('.flickr_result').html("");
    $('#spinner').show();
  });

  flickrForm.addEventListener("ajax:success", function (e) {
    $('#spinner').hide();
    $('.flickr_result').html(e.detail[0].body.innerHTML);
  });
});
