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
//= require jquery
//= require jquery_ujs

$(function () {

// Flickr functions

    function searchOnFlickr() {
        //found_obs.empty();
        $('.found_pictures').empty();
        $('.found_pictures').addClass('loading');
        var data = $(".flickr_search :input").serializeArray();
        $.ajax("/images/flickr_search", {
            data:data,
            success:function (data) {
                $('.found_pictures').removeClass('loading');
                if (data.length == 0) $("<div>", {text:'No results', class:'errors'}).appendTo('.found_pictures');
                else $(data).each(function () {
                    $("<img>", { "src":this.url_s }).data('id', this['id']).appendTo('.found_pictures');
                })
            },
            error:function (jqXHR, textStatus, errorThrown) {
                var error_message = $.parseJSON(jqXHR.responseText).error;
                $('.found_pictures').removeClass('loading');
                $('<div></div>', {class: 'errors', text: error_message}).appendTo('.found_pictures');
            }
        });
    }

// Search button click
    $('.flickr_search_btn').click(searchOnFlickr);

// Click on found image
    $(document).on('click', '.found_pictures img', function () {
        $('#image_flickr_id').val($(this).data('id'));
        $('form.flickr_edit').submit();
    });

});
