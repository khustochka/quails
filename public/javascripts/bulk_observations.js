$(function () {
    var form = $('form#bulk_observ_form[data-remote]'),

        options_list = $('.obs-row select.sp-suggest').children("option");

     // var cnt = 1;

    function addNewRow(event, ui) {
        var row = sample_row.clone(true).insertBefore('.buttons');
        //$('label:contains("Species:")', row).attr('for', 'observation_species_id_' + cnt);
        var suggest = $('.sp-suggest', row) /*.attr('id', 'observation_species_id_' + cnt)*/ ;
        if (arguments.length > 1) {
            suggest.children("option").each(function () {
                if ($(this).text() == ui.item.value) {
                    this.selected = true;
                    return false;
                }
            });
        }
        suggest.combobox();
        $("#observation_biotope", row).biotope();
        // cnt++;
        refreshSubmitAbility();
        return false;
    }

    function refreshSubmitAbility() {
        if ($('.obs-row').length == 0) {
            $('.buttons input:submit').prop('disabled', true);
        }
        else {
            $('.buttons input:submit').prop('disabled', false);
        }
    }

    $.rails.ajax = function (options) {
        if (options.url == form.data('action')) options.async = false;
        return $.ajax(options);
    };

    /* Form actions */
    form.attr('action', form.data('action'));

    form.on('ajax:beforeSend', function () {
        $(".errors").remove();
    });

    form.bind('ajax:success', function (e, data) {
        $(".obs-row").each(function (index) {
            var val = data[index];
            if (!$(this).data("db-id")) {
                $(this).data("db-id", val.id)
                    .addClass('has-id');
                $('input#observation_id', $(this)).val(val.id);
            }
            $(this).removeClass('save-fail').addClass('save-success');
        });
    });

    form.bind('ajax:error', function (event, xhr, status) {
        var errors = $.parseJSON(xhr.responseText),
            err_list = $("<ul>", {'class':'errors'}).prependTo("form#bulk_observ_form");
        $.each(errors, function (i, val) {
            if (i != "observs") $("<li>").text(i + " " + val[0]).appendTo(err_list);
        });
        $('.obs-row').each(function (i) {
            var row = $(this);
            if (errors.observs) $.each(errors.observs[i], function (ind, val) {
                $('input#observation_' + ind, row).after($('<span class="error">').text(val[0]));
            });
            row.removeClass('save-success').addClass('save-fail');
        });
    });

    $('#species-quick-add').autocomplete({
        delay:0,
        minLength:3,
        autoFocus:true,
        source:function (request, response) {
            var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
            response(options_list.map(function () {
                var text = $(this).text();
                if (( this.value != null ) && ( !request.term || matcher.test(text) ))
                    return {
                        label:text.replace('Avis incognita', '<i>Avis incognita</i>').replace(
                            new RegExp(
                                "(?![^&;]+;)(?!<[^<>]*)(" +
                                    $.ui.autocomplete.escapeRegex(request.term) +
                                    ")(?![^<>]*>)(?![^&;]+;)", "gi"
                            ), "<strong>$1</strong>"),
                        value:text
                    };
            }));
        },
        select:function (event, ui) {
            addNewRow(event, ui);
            $(this).val("");
            return false;
        }
    }).data("autocomplete")._renderItem = function (ul, item) {
        return $("<li></li>")
            .data("item.autocomplete", item)
            .append("<a>" + item.label + "</a>")
            .appendTo(ul);
    };

    if ($('#row_tmpl').length > 0) $($('#row_tmpl').text()).insertBefore('.buttons');
    $('.obs-row div.for-remove').
        append($("<span class='remove'><img src='/images/x_alt_16x16.png' title='Remove'></span>"));

    var sample_row = $('.obs-row:last').detach();
    $('.sp-suggest').combobox();
    refreshSubmitAbility();

    $('#add-row').click(addNewRow);

    $('form#bulk_observ_form').on('click', '.remove', function () {
        $(this).closest('.obs-row').remove();
        refreshSubmitAbility();
    });

    $('input#observation_locus_id').prop('required', true);
});