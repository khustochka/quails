Quails.pages.imageForm = {

  init: function () {

    $("#image_stored_image").on("change", this.fileSelected.bind(this));

  },

  fileSelected: function () {
    this.startUpload();
    this.fetchSlug();
  },

  startUpload: function () {
    var formData = new FormData();
    formData.append('stored_image', $('#image_stored_image')[0].files[0]);
    $.ajax({
      url: '/blobs',
      type: 'POST',
      data: formData,
      success: function (data) {
        alert(data);
      },
      error: function (data) {
        alert("Error");
      },
      cache: false,
      contentType: false,
      processData: false
    });
  },

  fetchSlug: function () {
    var newSlug = /([^\\.]+)(\.[^.\\]*)?$/.exec(document.getElementById("image_stored_image").files[0].name)[1];
    var currentSlug = $("#image_slug").val();

    if (newSlug &&
      (!currentSlug ||
        (currentSlug !== newSlug) && confirm("Do you want to replace slug with '" + newSlug + "'?")))
      $("#image_slug").val(newSlug);
  }

};
