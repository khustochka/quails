$(function() {
    var form = $('form#new_observation[data-remote]');

    form.attr('action', form.data('action'));
    form.bind('ajax:success', function(e, data) {
        if (data.result == "OK") {
            $(".obs-row").each( function(index) {
                var val = data.data[index];
                if (val.id) {
                    if (! $(this).data("db-id")) {
                        $(this).data("db-id", val.id)
                                .addClass('has-id')
                                .prepend($("<input type='hidden' name='o[][id]'>").attr('value', val.id));
                    }
                    $(this).removeClass('save-fail').addClass('save-success');
                }
                else $(this).removeClass('save-success').addClass('save-fail');
            })
        }
    });

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