$(function () {

    function searchOnFlickr() {
        //found_obs.empty();
        //$('.observation_options').addClass('loading');
        var data = $("input#flickr_text,input#flickr_date").serializeArray();
        $.get("/images/flickr_search", data, function (data) {
            $(data).each(function () {
                $("<img>", { "src":this.url_s }).appendTo('.flickr_search');
            });
        });
    }

    // Search button click
    $('.flickr_search_btn').click(searchOnFlickr);

});