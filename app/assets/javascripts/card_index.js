// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery_ujs
//= require suggest_over_combo
//= require jquery_pjax
//= require pjax_spinner

$(function () {
  // default timeout is causing page reload on heavy pages, like lifelist
  $('#cards_search_results').pjax('nav.pagination a');

  showSpinner(function () {
    $("nav.pagination", this).append("<img src='/img/loading_small.gif'>");
  });
});
