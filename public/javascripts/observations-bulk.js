$(function() {
    sample_row = $('.obs-row').detach();

    $('#add-row').click( function() { $(':submit').before(sample_row.clone()); } );
})(jQuery);