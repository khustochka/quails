$(function () {

  var box = $('#cse-query-box');

  if ($('#cse-query-box').length > 0) {

    box.autocomplete({
      source: '/species/search.json',
      appendTo: "#search-ui-front",
      select: function (event, ui) {
        window.location.href = ui.item.url;
        return false;
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
      $("<li>")
          .append('<a class="fallback_google">Search with Google</a>')
          .appendTo(ul);
    };

    box_autocomplete._renderItem = function (ul, item) {
      return $("<li>").append(
              $('<a href="' + item.url + '">')
                  .append('<b>' + item.name + "</b>\n")
                  .append('<i class="sci_name">' + item.label + "</i>")
          )
          .appendTo(ul);
    };

    $(document).on('click', '.fallback_google', function () {
      $('form#cse-search-box').submit();
    });

  }

});
