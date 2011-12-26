$(function () {

    function reviseSizes() {
      var clientHeight = $(window).height();
      $('ul.obs-list').height(clientHeight - 113);
      $('div#googleMap').height(clientHeight - 112);
      $('div#googleMap').width($(window).width() - 381);
    }

    reviseSizes();

    $(window).resize(reviseSizes);

});