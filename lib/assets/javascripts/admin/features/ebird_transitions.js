Quails.features.ebirdTransitions = {
  init: function () {
    $(document).on("ajax:beforeSend", ".ebird-trans", function () {
      $(this).closest(".status-line").append("<img src='/img/loading_small.gif' alt='loading'>");
    });
    $(document).on("ajax:success", ".ebird-trans", function (e) {
      var row;
      row = $(this).closest(".status-line");
      $(row).html(e.detail[0].status_line);
    });
  }
};
