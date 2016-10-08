Quails.pages.species_admin =

  init: ->
    $("#admin_sp_search").on "input", ->
      value = $(this).prop("value")
      $.ajax "/species/admin?term=#{value}", success: (data, status, xhr)->
        #data_html = $(data)
        #term = $(data_html).data("term")
        #data2 = data.replace(term, "<span class='hilite'>#{term}</span>")
        $(".species_list_container").html(data)
        return
    return
