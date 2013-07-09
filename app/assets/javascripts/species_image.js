$(function () {

  var current_image_id_field = $('#species_species_image_attributes_image_id');

  $('.edit_main_image').click(function () {
    $('div.thumbnails').css({border: "2px solid green", padding: "10px"});

    $('.image_thumb[data-image-id="' + current_image_id_field.val() + '"]', 'div.thumbnails')
        .css({border: "2px solid orange"});

    $('img', 'div.thumbnails').click(function (event) {
      event.preventDefault();
      current_image_id_field.val($(this).closest('figure').data('image-id'));
      $('form', 'div.thumbnails').submit();
    });

  });

});
