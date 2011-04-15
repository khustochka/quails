$(function() {
    var form = $('form#new_observation[data-remote]');
    form.attr('action', form.data('action'));
    
    var sample_row = $('.obs-row').detach();
    var cnt = 1;
    
    $('#add-row').click(function() {
        var row = sample_row.clone(true);
        $(':submit').before(row);
        row.find('label:contains("Species:")').attr('for', 'observation_species_id' + cnt);
        row.find('.sp-suggest').attr('id', 'observation_species_id' + cnt).combobox();
        cnt++;
        return false;
    });

    $('.remove').live('click', function() {
        $(this).parent().remove();
    });
});