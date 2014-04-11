#= require jquery_ujs
#= require jquery-ui.user
#= require search
#= require base
#= require pages/comments

$ ->
  jsController = $("body").data("js-controller")
  if (jsController)
    Quails.pages[jsController].init()
