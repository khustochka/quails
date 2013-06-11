//= require jquery_ujs

$(function () {

  var current_image_id = $('#species_image_id').val();

  $('.edit_main_image').click(function () {
    $('div.thumbnails').css({border: "2px solid green", padding: "10px"});

    $('.image_thumb[data-image-id="'+current_image_id+'"]', 'div.thumbnails').css({border: "2px solid orange"});

    $('img', 'div.thumbnails').click(function (event) {
      event.preventDefault();
      $('#species_image_id').val($(this).closest('figure').data('image-id'));
      $('form', 'div.thumbnails').submit();
    });

  });

});
