// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

$(function () {

// Flickr functions

  function searchOnFlickr() {
    //found_obs.empty();
    if ($(".flickr_search :input").length > 0) {
      $('.flickr_result').empty();
      $('.flickr_result').addClass('loading');
      var data = $(".flickr_search :input").serializeArray();
      $.ajax("/flickr/photos/search", {
        data: data,
        method: 'POST',
        success: function (data) {
          $('.flickr_result').removeClass('loading').html(data);

        },
        error: function (jqXHR, textStatus, errorThrown) {
          var error_message = $.parseJSON(jqXHR.responseText).error;
          $('.flickr_result').removeClass('loading');
          $('<div></div>', {class: 'errors', text: error_message}).appendTo('.flickr_result');
        }
      });
    }
  }

// Search button click
  $('.flickr_search_btn').click(searchOnFlickr);

// Click on found image
  $(document).on('click', '.found_pictures img', function () {
    $('#flickr_id').val($(this).data('id'));
    $('form.flickr_edit').submit();
    return false;
  });

  $('form.flickr_edit').on('ajax:success', function () {
    window.location.href = $('a.next_unflickred').attr('href');
  });

  $('form.flickr_edit').on('ajax:error', function (e, xhr) {
    alert(xhr.responseText.errors);
  });

  searchOnFlickr();

});
