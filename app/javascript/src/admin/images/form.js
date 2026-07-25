document.addEventListener("DOMContentLoaded", function () {
  const form = document.querySelector("[data-image-form]");
  if (!form) return;

  // A persisted image renders no upload UI, only a hidden field reusing the same id.
  const fileInput = document.querySelector("input[type=file]#image_stored_image");
  if (!fileInput) return;

  const droparea = document.querySelector(".droparea");
  const slugInput = document.getElementById("image_slug");

  function fileSelected() {
    startUpload(fileInput.files[0]);
  }

  function fetchSlug(filename) {
    const newSlug = /([^\\.]+)(\.[^.\\]*)?$/.exec(filename)[1];
    const currentSlug = slugInput.value;

    if (newSlug &&
      (!currentSlug ||
        (currentSlug !== newSlug) && confirm("Do you want to replace slug with '" + newSlug + "'?")))
      slugInput.value = newSlug;
  }

  function uploadFailed() {
    form.classList.remove("is-uploading");
    form.classList.add("upload-error");
  }

  function startUpload(file) {
    if (!file || form.classList.contains("is-uploading")) return false;

    fetchSlug(file.name);
    form.classList.add("is-uploading");
    form.classList.remove("upload-error");

    const formData = new FormData();
    formData.append("stored_image", file);

    // Without a token the upload cannot be authorized; the file input still holds
    // the file, so submitting the form attaches it the plain multipart way.
    const csrfMeta = document.querySelector("meta[name=csrf-token]");
    if (!csrfMeta) {
      uploadFailed();
      return false;
    }

    fetch("/blobs", { method: "POST", body: formData, headers: { "X-CSRF-Token": csrfMeta.content } })
      .then(function (r) {
        if (!r.ok) throw new Error("Upload failed");
        return r.json();
      })
      .then(function (data) {
        form.classList.remove("is-uploading");
        uploadFinished(data);
      })
      .catch(uploadFailed);
  }

  function uploadFinished(blob) {
    const preview = document.querySelector(".drop__preview");
    preview.innerHTML = "";
    const img = document.createElement("img");
    img.className = "upload-preview";
    img.src = blob.src;
    preview.appendChild(img);

    fileInput.value = "";
    let hiddenInput = form.querySelector("input[type=hidden]#image_stored_image");
    if (!hiddenInput) {
      hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.id = "image_stored_image";
      hiddenInput.name = "image[stored_image]";
      form.appendChild(hiddenInput);
    }
    hiddenInput.value = blob.signed_id;
    startAnalyze(blob);
  }

  function startAnalyze(blob) {
    const analyzing = document.querySelector(".drop__analyzing");
    analyzing.style.display = "block";

    if (blob.metadata.analyzed) {
      analyzeFinished(blob);
    } else {
      setTimeout(function () {
        fetch(blob.url)
          .then(function (r) {
            if (!r.ok) throw new Error("Analyze error");
            return r.json();
          })
          .then(function (data) { startAnalyze(data); })
          .catch(function () {
            analyzing.style.display = "none";
            alert("Analyzing error");
          });
      }, 1000);
    }
  }

  function analyzeFinished(blob) {
    document.querySelector(".drop__analyzing").style.display = "none";
    if (blob.metadata.exif_date) {
      document.getElementById("q_observ_date").value = blob.metadata.exif_date.substring(0, 10);
    }
  }

  // Init
  fileInput.addEventListener("change", fileSelected);

  const isAdvancedUpload = (function () {
    const div = document.createElement("div");
    return (("draggable" in div) || ("ondragstart" in div && "ondrop" in div)) && "FormData" in window && "FileReader" in window;
  })();

  if (isAdvancedUpload && droparea) {
    form.classList.add("has-advanced-upload");

    ["drag", "dragstart", "dragend", "dragover", "dragenter", "dragleave", "drop"].forEach(function (evt) {
      droparea.addEventListener(evt, function (e) {
        e.preventDefault();
        e.stopPropagation();
      });
    });

    ["dragover", "dragenter"].forEach(function (evt) {
      droparea.addEventListener(evt, function () { form.classList.add("is-dragover"); });
    });

    ["dragleave", "dragend", "drop"].forEach(function (evt) {
      droparea.addEventListener(evt, function () { form.classList.remove("is-dragover"); });
    });

    droparea.addEventListener("drop", function (e) {
      startUpload(e.dataTransfer.files[0]);
    });
  }
});
