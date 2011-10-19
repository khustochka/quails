$(function() {
    function refreshObservList() {
        if ($('ul.obs-list li').length == 0) {
            $("<li>", {'class': 'errors'}).html('None').prependTo("ul.obs-list");
            $('ul.obs-list').prevAll().html('&nbsp;');
            $('.buttons input:submit').prop('disabled', 'disabled');
        }
    }

    refreshObservList();

    $("#image_code").keyup(function() {
        $("img.image_pic").attr('src', $("img.image_pic").attr('src').
            replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
    });

    $('.remove').live('click', function() {
        $(this).closest('li').remove();
        refreshObservList();
    });
});
