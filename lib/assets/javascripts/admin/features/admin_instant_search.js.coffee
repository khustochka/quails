Quails.features.admin_instant_search =

  init: ->
    $this = this
    $this.dataUrl = $(".admin_instant_search_container").data("url")
    $("#admin_instant_search").on "input", ->
      value = $(this).prop("value")
      if $this.requestTimeout
        window.clearTimeout($this.requestTimeout)
      $this.requestTimeout = window.setTimeout($this.sendRequest(value), 500)
    return

  sendRequest: (value) ->
    $this = this
    return ->
      $.ajax "#{$this.dataUrl}?term=#{value}", success: (data, status, xhr)->
        #data_html = $(data)
        #term = $(data_html).data("term")
        #data2 = data.replace(term, "<span class='hilite'>#{term}</span>")
        $(".instant_search_container").html(data)
        return
