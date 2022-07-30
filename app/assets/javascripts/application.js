//= require search
//= require base

$(function () {
    var $body = $("body"),
        jsController = $body.data("js-controller"),
        jsFeatures = $body.data("js-features");

    if (jsController)
        Quails.pages[jsController].init();


    if (jsFeatures)
        for (var i = 0, _len = jsFeatures.length; i < _len; i++) {
            Quails.features[jsFeatures[i]].init()
        }
});
