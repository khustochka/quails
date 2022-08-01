
$(function () {

// Flickr functions

  function searchOnFlickr() {
    //found_obs.empty();
    if ($(".flickr_search :input").length > 0) {
      $('.flickr_result').empty();
      $('.found_pictures').addClass('loading');
      var data = $(".flickr_search :input").serializeArray();
      $.ajax("/flickr/photos/search", {
        data: data,
        method: 'POST',
        success: function (data) {
          $('.found_pictures').removeClass('loading');
          $('.flickr_result').html(data);

        },
        error: function (jqXHR, textStatus, errorThrown) {
          var error_message = $.parseJSON(jqXHR.responseText).error;
          $('.found_pictures').removeClass('loading');
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
    if ($('a.next_unflickred').length > 0) window.location.href = $('a.next_unflickred').attr('href');
    else $("<p></p>", {id: "notice", text: "Image updated"}).insertBefore(".flickr_search_table");
  });

  $('form.flickr_edit').on('ajax:error', function (e, xhr) {
    alert(JSON.stringify($.parseJSON(xhr.responseText).errors));
  });

  searchOnFlickr();

});
