//= require jquery_ujs

$(function () {

  var current_image_id = $('#species_image_id').val();

  $('.edit_main_image').click(function () {
    $('ul.thumbnails').css({border: "2px solid green", padding: "10px"});

    $('.imageholder[data-image-id="'+current_image_id+'"]', 'ul.thumbnails').css({border: "2px solid orange"});

    $('img', 'ul.thumbnails').click(function (event) {
      event.preventDefault();
      $('#species_image_id').val($(this).closest('li').data('image-id'));
      $('form', 'ul.thumbnails').submit();
    });

  });

});
