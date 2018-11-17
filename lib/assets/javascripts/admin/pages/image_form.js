Quails.pages.imageForm = {

  init: function () {

    $("#image_stored_image").on("change", this.fileSelected.bind(this));

    var isAdvancedUpload = function () {
      var div = document.createElement('div');
      return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
    }();

    if (isAdvancedUpload) {
      this.enableDragAndDrop();
    }

  },

  fileSelected: function () {
    this.startUpload($('#image_stored_image')[0].files[0]);
  },

  startUpload: function (file) {

    var $form = $("form.simple_form.image"), _this = this;

    if (!file || $form.hasClass('is-uploading')) return false;

    this.fetchSlug(file.name);

    $form.addClass('is-uploading').removeClass("upload-error");

    var formData = new FormData();
    formData.append('stored_image', file);
    $.ajax({
      url: '/blobs',
      type: 'POST',
      data: formData,
      complete: function () {
        $("form.simple_form.image").removeClass("is-uploading");
      },
      success: function (data) {
        _this.uploadFinished(data);
      },
      error: function (data) {
        $("form.simple_form.image").addClass("upload-error");
      },
      cache: false,
      contentType: false,
      processData: false,
      dataType: "json"
    });
  },

  fetchSlug: function (filename) {
    var newSlug = /([^\\.]+)(\.[^.\\]*)?$/.exec(filename)[1];
    var currentSlug = $("#image_slug").val();

    if (newSlug &&
      (!currentSlug ||
        (currentSlug !== newSlug) && confirm("Do you want to replace slug with '" + newSlug + "'?")))
      $("#image_slug").val(newSlug);
  },

  enableDragAndDrop: function () {
    var _this = this,
      $form = $("form.simple_form.image");

    $form.addClass('has-advanced-upload');

    $(".droparea").on('drag dragstart dragend dragover dragenter dragleave drop', function (e) {
      e.preventDefault();
      e.stopPropagation();
    })
      .on('dragover dragenter', function () {
        $form.addClass('is-dragover');
      })
      .on('dragleave dragend drop', function () {
        $form.removeClass('is-dragover');
      })
      .on('drop', function (e) {

        _this.startUpload(e.originalEvent.dataTransfer.files[0]);
      });

  },

  uploadFinished: function(blob) {
    $("<img>").addClass("upload-preview").attr("src", blob.src).appendTo(".drop__preview");
    $("input[type=file]#image_stored_image").val("");
    var hiddeninput = $("input[type=hidden]#image_stored_image");
    if (hiddeninput.length < 1) $("<input>", {type: "hidden", id: "image_stored_image", name: "image[stored_image]"}).appendTo("form.image");
    $("input[type=hidden]#image_stored_image").val(blob.signed_id);
    this.startAnalyze(blob)
  },

  startAnalyze: function(blob) {
    var _this = this;
    $(".drop__analyzing").show();

    if (blob.metadata.analyzed) {
      this.analyzeFinished(blob);
    }
    else {
      setTimeout(function() {

        $.ajax({
          url: blob.url,
          type: 'GET',
          dataType: "json",
          error: function() {$(".drop__analyzing").hide(); alert("Analyzing error");},
          success: function(data) {_this.startAnalyze(data)}
          }
        )
      }, 1000)
    }
  },

  analyzeFinished: function(blob) {
    $(".drop__analyzing").hide();
    if (blob.metadata.exif_date) $("input#q_observ_date").val(blob.metadata.exif_date.substring(0, 10));
  }


};
