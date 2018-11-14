Quails.pages.imageForm = {

  init: function () {

    $("#image_stored_image").on("change", this.fetchSlug);

  },

  fetchSlug: function () {
    var newSlug = /([^\\.]+)(\.[^.\\]*)?$/.exec(this.files[0].name)[1];
    var currentSlug = $("#image_slug").val();
    
    if (newSlug &&
        (!currentSlug || 
          (currentSlug != newSlug) && confirm("Do you want to replace slug with '" + newSlug + "'?")))
        $("#image_slug").val(newSlug);
  }

};
