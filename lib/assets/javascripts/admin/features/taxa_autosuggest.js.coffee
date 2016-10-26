Quails.features.taxaAutosuggest =

  init: ->
    return

  initTaxonSuggestField: (elements, onSelect) ->
    selectFunc = onSelect || (event, ui) ->
      $(this).val ui.item.value
      $(this).next().val ui.item.id
      false
    input = $(elements)
    if input.length > 0
      input.autocomplete
        delay: 0
        autoFocus: true
        source: "/taxa/search.json"
        minLength: 2
        select: selectFunc
      input.each (i) ->
        $(this).data("ui-autocomplete")._renderItem = (ul, item) ->
          $('<li></li>').
          data('item.autocomplete', item).
          append("<a>#{item.label} <small class=\"tag tag_#{item.cat}\">#{item.cat}</small></a>").
          appendTo ul
        return
    return
