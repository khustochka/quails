#= require jquery
#= require jquery_ujs
#= require jquery-ui.user
#= require search
#= require base

$ ->
  jsController = $("body").data("js-controller")
  if (jsController)
    Quails.pages[jsController].init()

  jsFeatures = $("body").data("js-features")
  if (jsFeatures)
    for feature in jsFeatures
      Quails.features[feature].init()


