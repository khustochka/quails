$(function () {

  $(".card_observations_private_notes").hide();
  $(".observation_private_notes").hide();

  $(document).on("click", ".priv_notes", function () {
    $(this).parent().next().toggle();
  });

});
