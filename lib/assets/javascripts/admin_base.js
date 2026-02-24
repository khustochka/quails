//= require_self
//= require_tree ./admin/features
//= require_tree ./admin/pages

this.Quails = {
  pages: {},
  features: {}
};

document.addEventListener('DOMContentLoaded', function () {
    const $body = document.querySelector("body"),
        jsController = $body.getAttribute("data-js-controller"),
        jsFeaturesStr = $body.getAttribute("data-js-features"),
        jsFeatures = JSON.parse(jsFeaturesStr);

    if (jsController)
        Quails.pages[jsController].init();

    if (jsFeatures)
        jsFeatures.forEach(feature => Quails.features[feature].init())
});
