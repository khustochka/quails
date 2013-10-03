$(function () {

  var current_parent_id = $('.thumbnails').data('current-parent'),
      patch_url = $('.thumbnails').data('patch-url');


  $('.image_thumb[data-image-id="' + current_parent_id + '"]', 'div.thumbnails')
      .addClass('orange_border');

  $('img', 'div.thumbnails').click(function (event) {
    event.preventDefault();
    var new_parent =  $(this).closest('figure').data('image-id');
    $.post(patch_url, {'parent_id': new_parent}, function(data) {
      $('.image_thumb[data-image-id="' + current_parent_id + '"]', 'div.thumbnails')
          .removeClass('orange_border');

      current_parent_id = new_parent;

      $('.image_thumb[data-image-id="' + current_parent_id + '"]', 'div.thumbnails')
          .addClass('orange_border');

    });
  });


});
