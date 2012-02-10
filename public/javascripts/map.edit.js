$(function () {

    function adjustSizes() {
      var clientHeight = $(window).height(),
          upper = $('#header').outerHeight(true) + $('#new_q').outerHeight();
      $('ul.obs-list').height(clientHeight - upper - 1);
      $('div#googleMap').height(clientHeight - upper);
      $('div#googleMap').width($(window).width() - 381);
    }

    adjustSizes();

    $(window).resize(adjustSizes);

});