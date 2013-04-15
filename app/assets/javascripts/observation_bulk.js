// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery_ujs
//= require jquery-ui.custom
//= require suggest_over_combo

$(function () {
    var form = $('form#bulk_observ_form[data-remote]'),

        options_list = $('.obs-row:first select.sp-suggest').children("option");

    var cnt = 1;

    function addNewRow(event, ui) {
        var row = sample_row.clone(true).insertBefore('.buttons');
        $('#observation_voice', row).attr('id', 'observation_voice_' + cnt);
        $('label:contains("Voice?")', row).attr('for', 'observation_voice_' + cnt);
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
        cnt++;
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

    /* Form actions */
    form.attr('action', form.data('action'));

    form.on('ajax:beforeSend', function () {
        $(".errors").remove();
        $(".obs-row").removeClass('save-fail').removeClass('save-success');
    });

    form.on('ajax:success', function (e, data) {
        $(".obs-row").each(function (index) {
            var val = data[index];
            $('input#observation_id', $(this)).val(val.id);
            $(this).addClass('save-success');
        });
    });

    form.on('ajax:error', function (event, xhr, status) {
        var errors = $.parseJSON(xhr.responseText).errors,
            err_list = $("<ul>", {'class':'errors'}).prependTo("form#bulk_observ_form");
        $.each(errors, function (i, val) {
            if (i != "observs") $("<li>").text(i + " " + val[0]).appendTo(err_list);
        });
        $('.obs-row').each(function (i) {
            var row = $(this);
            if (errors.observs) $.each(errors.observs[i], function (ind, val) {
                $('input#observation_' + ind, row).after($('<span class="error">').text(val[0]));
            });
            row.addClass('save-fail');
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
    $('.obs-row').
        append($("<span class='remove'><img src='/img/x_14x14.png' title='Remove'></span>"));

    var sample_row = $('.obs-row:last').detach();
    $('.sp-suggest').combobox();
    refreshSubmitAbility();

    $('#add-row').click(addNewRow);
    $('#hide-saved').click(function(){
        $(".obs-row.save-success").remove();
        refreshSubmitAbility();
    });

    $('form#bulk_observ_form').on('click', '.remove', function () {
        $(this).closest('.obs-row').remove();
        refreshSubmitAbility();
    });

    $('input#observation_locus_id').prop('required', true);
});
