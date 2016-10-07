#= require jquery-ui.addon
#= require suggest_over_combo
#= require card_observ_form_shared
#= require keypress

Quails.pages.cards =

  init: ->
    @initObservationRows()
    @initDatepicker()
    @initLocusAutocomplete()
    @initPatchAutocomplete()
    @initAddRows()
    @initRemoveAndDestroy()
    @initFastSpeciesLinks()
    @initQuickAdd()
    @initSpeciesAutocomplete()
    @initMarkAsVoice()

  initObservationRows: ->
    $(".card_observations_private_notes").hide()
    @last_row_num = $('.obs-row').length - 1
    @sample_row_html = $('.obs-row:last')[0].outerHTML
    @tmpl_regex = new RegExp("(_|\\[)#{@last_row_num}(_|\\])", "g")
    $('.obs-row:last').remove()

  initDatepicker: ->
    datefield = $('#card_observ_date')
    currentDate = datefield.val()
    datefield.attr 'type', 'hidden'
    datefield.parent().hide()
    $('<div class=\'inline_date\'></div>').prependTo 'form.simple_form'
    $('.inline_date').datepicker
      dateFormat: 'yy-mm-dd'
      firstDay: 1
      altField: datefield
      altFormat: 'yy-mm-dd'
      defaultDate: currentDate

  initLocusAutocomplete: ->

    $("select#card_locus_id").combobox();
    # Mark autocomplete locus field as required
    $('input#card_locus_id').prop('required', true)

    # Fast locus selector
    $('.fast_locus').click ->
      $("input#card_locus_id").data('ui-autocomplete').search(this.textContent)
      $(".ui-menu-item a:contains(#{this.textContent}):first").click()

  initPatchAutocomplete: ->
    $('.patch-suggest').combobox()

  initAddRows: ->
    $('#add-row').click =>
      @addNewRow()
      window.scrollTo 0, $(document).height()

  initRemoveAndDestroy: ->
    $('form.simple_form').on 'click', '.remove', ->
      $(this).closest('.obs-row').remove()
      return

    $('a.destroy').data('remote', 'true').on('ajax:success', ->
      row = $(this).closest('.obs-row')
      row.next().remove()
      row.remove()
      return
    ).on 'ajax:error', ->
      alert 'Error removing observation'
      return

  initFastSpeciesLinks: ->
    global = @
    $('.fast-sp-link').click ->
      row = global.addNewRow()
      $('.sp-light', row).val @innerText
      $('.sp-light', row).next().val $(this).data('taxon-id')
      false

  initQuickAdd: ->
    $('#species-quick-add').autocomplete
      delay: 0
      autoFocus: true
      source: "/taxa/search.json"
      minLength: 2
      select: (event, ui) =>
        row = @addNewRow()
        $('.sp-light', row).val ui.item.value
        $('.sp-light', row).next().val ui.item.id
        $('#species-quick-add').val ''
        window.scrollTo 0, $(document).height()
        false

    $('#species-quick-add').data('ui-autocomplete')._renderItem = (ul, item) ->
      $('<li></li>').
      data('item.autocomplete', item).
      append("<a>#{item.label} <small class=\"tag tag_#{item.cat}\">#{item.cat}</small></a>").
      appendTo ul

    @preventSubmitOnEnter()

  preventSubmitOnEnter: ->
    # Prevent submit on Enter
    $('#species-quick-add').keydown (event) ->
      if event.keyCode == 13 and !event.ctrlKey
        event.preventDefault()
        return false
      else if event.keyCode == 13 and event.ctrlKey
        $('.simple_form').submit()
      return

  initExtractorAndMover: ->
    # Extract and move to the new card
    $('.extractor').click (e) ->
      window.location.href = $('.extractor').attr('href') + '?' + $('input[name="obs[]"]:checked').serialize()
      e.preventDefault()
      return
    $('.mover').click (e) ->
      window.location.href = $('.mover').attr('href') + '?' + $('input[name="obs[]"]:checked').serialize()
      e.preventDefault()
      return

  initMarkAsVoice: ->
    # Alt+V to mark as voice
    keypress = new (window.keypress.Listener)
    keypress.simple_combo 'alt v', ->
      checkbox = undefined
      focused = $(':focus')
      row = focused.closest('.obs-row')
      if row.length == 0 and focused.attr('id') == 'species-quick-add'
        row = $('.obs-row:last')
      checkbox = $('div.card_observations_voice input.boolean', row)
      checkbox.prop 'checked', !checkbox.prop('checked')
      return

  initSpeciesAutocomplete: ->
    @initAutocompleteField("")

  addNewRow: ->
    @last_row_num++
    row_html = @sample_row_html.replace(@tmpl_regex, '$1' + @last_row_num + '$2')
    $(row_html).appendTo $('.obs-block')
    @initAutocompleteField '.obs-row:last'
    $('.obs-row:last .patch-suggest').combobox()
    $ '.obs-row:last'

  initAutocompleteField: (parent) ->
    input = $(parent + ' .sp-light')
    if input.length > 0
      input.autocomplete
        delay: 0
        autoFocus: true
        source: "/taxa/search.json"
        minLength: 2
        select: (event, ui) ->
          $(this).val ui.item.value
          $(this).next().val ui.item.id
          false
      input.data('ui-autocomplete')._renderItem = (ul, item) ->
        $('<li></li>').
          data('item.autocomplete', item).
          append("<a>#{item.label} <small class=\"tag tag_#{item.cat}\">#{item.cat}</small></a>").
          appendTo ul
    return

