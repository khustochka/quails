$(function () {
  $('#spinner').hide();

  $('form').on("ajax:send", function() {
    $('#spinner').show();
  });

  $('form').on("ajax:success", function(e, data) {
    $('#spinner').hide();
    $('.flickr_result').html(data);
  });


});
