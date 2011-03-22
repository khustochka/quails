$(function() {
    var sample_row = $('.obs-row').detach();
    // TODO: autosuggest is not working in the new fields
    $('#add-row').click( function() {
        $(':submit').before( sample_row.clone(true) );
        return false;
    } );

    $(".remove").click(function() {
        $(this).parent().remove();
    });

});