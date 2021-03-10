import consumer from "../../channels/consumer"

document.addEventListener('DOMContentLoaded', function () {

  let form = document.getElementById("ebird_refresh_form");

  // if (form) form.addEventListener("ajax:success", function () {
  //   console.log("Success");
  // },
  //     //useCapture = required to use with UJS Ajax events(?)
  // true)

  // Why it does not work without jQuery?
  if (form) $(form).on("ajax:success", form, function () {
    consumer.subscriptions.create({ channel: "EbirdImportsChannel" }, {
      received(data) {
        console.log(data);
        this.unsubscribe();
      }})
    });

});