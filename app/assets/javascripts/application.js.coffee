#= require jquery_ujs
#= require jquery-ui.user
#= require base
#= require search
#= require comments

$ ->
  jsController = $("body").data("js-controller")
  if (jsController)
    Quails[jsController].init()
