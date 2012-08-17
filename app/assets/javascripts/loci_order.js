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
//= require jquery-ui.custom

$(function () {

    $('.public, .other').sortable({
        connectWith:'.drag_locs'
    }).disableSelection();

    $('.public').sortable("option",
        {
            update:function () {
                var result = $('.public li').map( function(i, el) {
                    return $(el).data('loc-id');
                }).get();
                $.ajax({
                    url: "/loci/save_order",
                    type: "POST",
                    data: JSON.stringify({order: result}),
                    processData: false,
                    contentType: "application/json; charset=utf-8"
                });
            }

        });
});
