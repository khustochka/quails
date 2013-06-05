//= require jquery_ujs

$(function () {

  var max_width;

  function refresh() {

    $(".thumbnails").remove();

    $(".main").css({"width": "100%", "max-width": "none"});

    var max_width = $(".main").innerWidth();

    $.get(window.location.href + "?width=" + max_width, function (data) {
      $(".main").append(data);
      $(".thumbs_row").css({width: max_width});
    });
  }

  refresh();

  $(window).resize(refresh);

});
