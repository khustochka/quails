$(function() {
    var form = $('form#new_observation[data-remote]');

    var options_list = $('.obs-row select.sp-suggest').children("option");

    function addNewRow(event, ui) {
        var row = sample_row.clone(true);
        $('.buttons').before(row);
        row.find('label:contains("Species:")').attr('for', 'observation_species_id' + cnt);
        row.find('.sp-suggest').attr('id', 'observation_species_id' + cnt).combobox();
        if (arguments.length > 2) {
            var selectedValue = arguments[2];
            row.find('input.ui-autocomplete-input').val(selectedValue);
            row.find('select.sp-suggest:hidden').children("option").each(function() {
                if ($(this).text() == selectedValue) {
                    this.selected = true;
                    return false;
                }
            });
        }
        cnt++;
        return false;
    }

    /* On form submit */
    form.attr('action', form.data('action'));
    form.bind('ajax:success', function(e, data) {
        $(".errors").remove();
        if (data.result == "OK") {
            $(".obs-row").each(function(index) {
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
        else {
            var err_list = $("<ul>", {'class': 'errors'}).prependTo("form#new_observation");
            for (var i in data.data) {
                var new_p = $("<li>").append(document.createTextNode(i + " " + data.data[i]));
                err_list.append(new_p);
            }
        }
    });

    $('#species-quick-add').autocomplete({
        delay: 0,
        minLength: 3,
        autoFocus: true,
        source: function(request, response) {
            var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
            response(options_list.map(function() {
                var text = $(this).text();
                if (( this.value != null ) && ( !request.term || matcher.test(text) ))
                    return {
                        label: text.replace('Avis incognita', '<i>Avis incognita</i>').replace(
                                new RegExp(
                                        "(?![^&;]+;)(?!<[^<>]*)(" +
                                                $.ui.autocomplete.escapeRegex(request.term) +
                                                ")(?![^<>]*>)(?![^&;]+;)", "gi"
                                        ), "<strong>$1</strong>"),
                        value: text
                    };
            }));
        },
        select: function(event, ui) {
            addNewRow(event, ui, ui.item.value);
            $(this).val("");
            return false;
        }
    }).data("autocomplete")._renderItem = function(ul, item) {
        return $("<li></li>")
                .data("item.autocomplete", item)
                .append("<a>" + item.label + "</a>")
                .appendTo(ul);
    };

    $('.obs-row div:last').
        append($("<span class='pseudolink remove'><img src='/images/x_alt_16x16.png' title='Remove'></span>"));
    var sample_row = $('.obs-row').detach();
    var cnt = 1;

    $('#add-row').click(addNewRow);

    $('.remove').live('click', function() {
        $(this).closest('.obs-row').remove();
    });

    $('.to-add-row').toggle(true);
});