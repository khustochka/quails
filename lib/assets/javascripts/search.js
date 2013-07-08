$(function () {

  if ($('#cse-query-box').length > 0) {

    $('#cse-query-box').autocomplete({
      source: '/species/search.json'
    }).data("ui-autocomplete")._renderItem = function (ul, item) {
      return $("<li>")
          .append('<a href="' + item.url + '">' + item.label + "</a>")
          .appendTo(ul);
    };

  }

});
