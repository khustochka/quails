#= require jquery_ujs
#= require jquery-ui.user
#= require search
#= require base

$ ->
  jsController = $("body").data("js-controller")
  if (jsController)
    Quails.pages[jsController].init()
