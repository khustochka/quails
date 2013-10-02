$(function () {
  $('#spinner').hide();

  $('form').on("ajax:send", function() {
    $('.flickr_result').html("");
    $('#spinner').show();
  });

  $('form').on("ajax:success", function(e, data) {
    $('#spinner').hide();
    $('.flickr_result').html(data);
  });


});
