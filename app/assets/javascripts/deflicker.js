$(function() {
  $(document).on("ajax:success", "form.push_form", function(e) {
    $(e.target).replaceWith("<div>Enqueued</div>");
  });
  $(document).on("ajax:success", "form.destroy_button", function(e) {
    document.location.reload();
  });
});
