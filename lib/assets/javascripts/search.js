// back to jQuery because document.addEventListener is not supported by IE8
//$(document).on("turbolinks:load", function() {
$(document).ready(function() {

  var box = $('#cse-query-box'), term_regex,
      form = box.closest("form");

  function autoHighlight(text) {
    return text.replace(term_regex, "<em>$1</em>");
  }

  if (box.length > 0) {

    $("#search-ui-front ul").css("width", $(box).outerWidth() + "px")

    box.autocomplete({
      source: $('[data-search-url]').data('search-url'),
      appendTo: "#search-ui-front",
      open: function() {
        $("#search-ui-front ul").width($(box).outerWidth() - 1);
      },
      select: function (event, ui) {
        if (ui.item.value.length === 0)
          $(form).submit();
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
          .data("ui-autocomplete-item", {value: ""})
          .append('<a class="fallback_link">' + $("[data-search-url]").data("fallback-text") + '</a>')
          .appendTo(ul);
    };

    box_autocomplete._renderItem = function (ul, item) {
      return $("<li></li>")
          .data("ui-autocomplete-item", item)
          .append(
              $('<a href="' + item.url + '"></a>')
                  .append('<b>' + autoHighlight(item.name) + "</b>\n")
                  .append('<i class="sci_name">' + autoHighlight(item.label) + "</i>")
          )
          .appendTo(ul);
    };

    box.on("focus", function () {
      $(this).autocomplete( "search" );
    });

  }

});
