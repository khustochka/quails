Quails.features.taxaAutosuggest = {
  init: function () {
  },
  initTaxonSuggestField: function (elements, onSelect) {
    var input, selectFunc;
    selectFunc = onSelect || function (event, ui) {
      $(this).val(ui.item.value);
      $(this).next().val(ui.item.id);
      return false;
    };
    input = $(elements);
    if (input.length > 0) {
      input.autocomplete({
        delay: 0,
        autoFocus: true,
        source: "/taxa/search.json",
        minLength: 2,
        select: selectFunc
      });
      input.each(function (i) {
        $(this).data("ui-autocomplete")._renderItem = function (ul, item) {
          return $('<li></li>').data('ui-autocomplete-item', item).append("<a>" + item.label + " <small class=\"tag tag_" + item.cat + "\">" + item.cat + "</small></a>").appendTo(ul);
        };
      });
    }
  }
};
