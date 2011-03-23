$(function() {
    var sample_row = $('.obs-row').detach();
    
    $('#add-row').click(function() {
        var row = sample_row.clone(true);
        $(':submit').before(row);
        row.find('.sp-suggest').combobox();
        return false;
    });

    $('.remove').live('click', function() {
        $(this).parent().remove();
    });
});