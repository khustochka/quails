Quails.InstantSearch = class {
  constructor(container) {
    this.container = $(container);
    this.dataUrl = this.container.data("url");
    let resultContainer = this.container.data("result-container");
    if (!resultContainer || resultContainer.length === 0) resultContainer = $(".instant_search_results", this.container);
    if (!resultContainer || resultContainer.length === 0) resultContainer = this.container.next(".instant_search_results");
    this.resultContainer = resultContainer;
    this.requestTimeout = null;
  }

  register() {
    const _this = this;
    this.container.on("input", ".instant_search_input", function () {
      let value = $(this).prop("value");
      if (_this.requestTimeout) window.clearTimeout(_this.requestTimeout);
      _this.requestTimeout = window.setTimeout(function () {
        _this.sendRequest(value)
      }, 500)
    });
  }

  sendRequest(value) {
    const _this = this;
    $.ajax(_this.dataUrl + "?term=" + value, {
      success: function (data, status, xhr) {
        $(_this.resultContainer).html(data)
      }
    })
  }
}

document.addEventListener('DOMContentLoaded', function () {
  $(".instant_search_container").each(function (i, el) {
    const instantSearch = new Quails.InstantSearch(el);
    instantSearch.register();
  });
})
