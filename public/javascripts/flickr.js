$(function() {

    function searchOnFlickr() {
        //found_obs.empty();
        //$('.observation_options').addClass('loading');
        var data = $("input#flickr_text,input#flickr_date").serializeArray();
        $.ajax({
            type : "GET",
            url : "/images/flickr_search",
            data : data,
            success : function(data) {
                $(data).each(function() {
                    $("<img>", { "src": this.url_s }).appendTo('.flickr_search');
                });
            }
        });
    }

    // Search button click
    $('.flickr_search_btn').click(searchOnFlickr);

});