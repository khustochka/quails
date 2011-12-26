$(function () {

    function reviseSizes() {
      var clientHeight = $(window).height(),
          upper = $('#header').outerHeight(true) + $('#new_search').outerHeight();
      $('ul.obs-list').height(clientHeight - upper - 1);
      $('div#googleMap').height(clientHeight - upper);
      $('div#googleMap').width($(window).width() - 381);
    }

    reviseSizes();

    $(window).resize(reviseSizes);

});