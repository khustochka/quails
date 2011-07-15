$(function() {
    $("#image_code").keyup(function() {
        $("img.image_pic").attr('src', $("img.image_pic").attr('src').
            replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
    });
});
