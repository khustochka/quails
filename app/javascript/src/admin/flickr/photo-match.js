// Flickr image search and attach
document.addEventListener("DOMContentLoaded", function() {
  var searchSection = document.querySelector("[data-flickr-photo-search]");
  if (!searchSection) return;

  var result = document.querySelector("[data-flickr-result]");
  var pictures = document.querySelector("[data-flickr-pictures]");
  var flickrForm = document.querySelector("[data-flickr-edit]");
  var flickrIdInput = document.querySelector("[data-flickr-id]");

  function searchOnFlickr() {
    var inputs = searchSection.querySelectorAll("input");
    if (inputs.length === 0) return;

    result.innerHTML = "";
    pictures.classList.add("loading");

    var formData = new FormData();
    inputs.forEach(function(input) {
      formData.append(input.name, input.value);
    });

    var token = document.querySelector("meta[name=csrf-token]").content;

    fetch("/flickr/photos/search", {
      method: "POST",
      headers: {"X-CSRF-Token": token},
      body: formData
    }).then(function(response) {
      pictures.classList.remove("loading");
      if (response.ok) return response.text();
      return response.json().then(function(json) { throw new Error(json.error); });
    }).then(function(html) {
      result.innerHTML = html;
    }).catch(function(err) {
      var div = document.createElement("div");
      div.className = "errors";
      div.textContent = err.message;
      result.appendChild(div);
    });
  }

  // Search button click
  document.querySelector("[data-flickr-search-btn]").addEventListener("click", searchOnFlickr);

  // Click on found image
  pictures.addEventListener("click", function(e) {
    var img = e.target.closest("img");
    if (!img) return;
    e.preventDefault();
    flickrIdInput.value = img.dataset.id;
    flickrForm.requestSubmit();
  });

  flickrForm.addEventListener("ajax:success", function() {
    var nextLink = document.querySelector("[data-next-unflickred]");
    if (nextLink) {
      window.location.href = nextLink.href;
    } else {
      var p = document.createElement("p");
      p.id = "notice";
      p.textContent = "Image updated";
      document.querySelector("[data-flickr-search-table]").before(p);
    }
  });

  flickrForm.addEventListener("ajax:error", function(e) {
    var response = e.detail[0];
    var errors = response.errors;
    var messages = Object.keys(errors).map(function(key) {
      return key + " " + [].concat(errors[key]).join(", ");
    });
    var div = document.createElement("div");
    div.className = "errors";
    div.textContent = messages.join("; ");
    result.innerHTML = "";
    result.appendChild(div);
  });

  searchOnFlickr();
});
