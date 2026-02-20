document.addEventListener('DOMContentLoaded', function () {

  const currentImageIdField = document.getElementById('species_species_image_attributes_image_id');

  document.querySelector('.edit_main_image').addEventListener('click', function () {
    const thumbnails = document.querySelector('div.thumbnails');
    thumbnails.style.border = '2px solid green';
    thumbnails.style.padding = '10px';

    thumbnails.querySelector('.image_thumb[data-image-id="' + currentImageIdField.value + '"]')
      ?.classList.add('orange_border');

    thumbnails.addEventListener('ajax:success', function () {
      location.reload();
    });

    thumbnails.querySelectorAll('img').forEach(function (img) {
      img.addEventListener('click', function (event) {
        event.preventDefault();
        currentImageIdField.value = img.closest('figure').dataset.imageId;
        thumbnails.querySelector('form').requestSubmit();
      });
    });
  });

});
