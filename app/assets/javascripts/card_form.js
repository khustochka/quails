//= require jquery_ujs
//= require jquery-ui.custom
//= require suggest_over_combo


$(function () {

    var sample_row_html = $('.obs-row:last')[0].outerHTML,
        last_row_num = $('.obs-row').length - 1,
        template_row_num = last_row_num,
        tmpl_regex = new RegExp("(_|\\[)" + template_row_num + "(_|\\])", "g");

    function addNewRow() {
        last_row_num++;
        var row_html = sample_row_html.replace(tmpl_regex, "$1" + last_row_num + "$2");
        $(row_html).insertBefore('#add-row');
        $('.obs-row:last .sp-suggest').combobox();
    }

    $('#add-row').click(addNewRow);
    $('.sp-suggest').combobox();

});
