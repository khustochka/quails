Quails.features.admin_instant_search =

  init: ->
    data_url = $(".admin_instant_search_container").data("url")
    $("#admin_instant_search").on "input", ->
      value = $(this).prop("value")
      $.ajax "#{data_url}?term=#{value}", success: (data, status, xhr)->
        #data_html = $(data)
        #term = $(data_html).data("term")
        #data2 = data.replace(term, "<span class='hilite'>#{term}</span>")
        $(".instant_search_container").html(data)
        return
    return
