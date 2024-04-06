//= require jquery-ui.addon

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
