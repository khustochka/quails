import consumer from "../../channels/consumer"

document.addEventListener('DOMContentLoaded', function () {

  function refreshComboboxes() {
    $("select.locus_select").combobox();
    // Mark autocomplete locus field as required
    // $('input#c__locus_id').prop('required', true);
  }

  refreshComboboxes();

  let form = document.getElementById("ebird_refresh_form"),
      container = $(".preloads-container");

  // if (form) form.addEventListener("ajax:success", function () {
  //   console.log("Success");
  // },
  //     //useCapture = required to use with UJS Ajax events(?)
  // true)

  // Why it does not work without jQuery?
  if (form) $(form).on("ajax:success", form, function () {
    consumer.subscriptions.create({ channel: "EBirdImportsChannel" }, {
      received(data) {
        container.html(data);
        this.unsubscribe();
        refreshComboboxes();
        var paramName = document.querySelector('meta[name=csrf-param]').content,
          csrfToken = document.querySelector('meta[name=csrf-token]').content;
        $("input[name=" + paramName + "]", container).val(csrfToken);
      }
    });
    container.html("<p><i class=\"fas fa-spinner fa-spin\"></i> Please wait, refreshing the checklists</p>");
    });
});
