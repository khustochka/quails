$(function () {

  var box = $('#cse-query-box'), term_regex;

  function autoHighlight(text) {
    return text.replace(term_regex, "<em>$1</em>");
  }

  if ($('#cse-query-box').length > 0) {

    box.autocomplete({
      source: $('#cse-wrapper').data('search-url'),
      appendTo: "#search-ui-front",
      select: function (event, ui) {
        if (ui.item === undefined)
          $('form#cse-search-box').submit();
        else
          window.location.href = ui.item.url;
        return false;
      },
      search: function (event, ui) {
        term_regex = new RegExp("(?!<^| |-)(" + $.ui.autocomplete.escapeRegex($(event.target).val()) + ")", "i");
      },
      // Prevent filling with focused value
      focus: function (event, ui) {
        return false;
      }
    });

    var box_autocomplete = box.data("ui-autocomplete");

    box_autocomplete.__renderMenu = box_autocomplete._renderMenu;

    box_autocomplete._renderMenu = function (ul, items) {
      var that = this;
      that.__renderMenu(ul, items);
      $('<li class="fallback_item">')
          .append('<a class="fallback_link">Найти больше</a>')
          .appendTo(ul);
    };

    box_autocomplete._renderItem = function (ul, item) {
      return $("<li></li>")
          .data("item.autocomplete", item)
          .append(
              $('<a href="' + item.url + '"></a>')
                  .append('<b>' + autoHighlight(item.name) + "</b>\n")
                  .append('<i class="sci_name">' + autoHighlight(item.label) + "</i>")
          )
          .appendTo(ul);
    };

  }

});
