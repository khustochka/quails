$(function() {
    $("#image_code").keyup( function() {
        $("img.image_pic").attr('src', "http://birdwatch.org.ua/photos/tn_" + $(this).val() + ".jpg");
    });
});
