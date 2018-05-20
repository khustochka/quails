$(function () {
    $("select.locus_select").combobox();
    // Mark autocomplete locus field as required
    $('input#c__locus_id').prop('required', true);
});
