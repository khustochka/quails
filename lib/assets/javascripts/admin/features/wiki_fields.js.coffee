Quails.features.wikiFields =
  init: ->
    textarea = $(".wiki_field")[0]
    sp_insert_button = $("<button>",
      text: "{{species}}"
      id: "insert_sp_tag"
      type: "button"
    )
    img_insert_button = $("<button>",
      text: "{{^image}}"
      id: "insert_img_tag"
      type: "button"
    )
    post_insert_button = $("<button>",
      text: "{{#post}}"
      id: "insert_post_tag"
      type: "button"
    )

    # Add a button
    $("<div>",
      class: "edit_tools"
    ).insertBefore textarea

    sp_insert_button.click =>
      @insertTags textarea, "{{", "|}}", "вид"
      return

    img_insert_button.click =>
      @insertTags textarea, "{{^", "}}", "img_slug"
      return

    post_insert_button.click =>
      @insertTags textarea, "{{#", "|}}", "post"
      return

    $(".edit_tools").append(sp_insert_button).append(img_insert_button).append post_insert_button

  insertTags: (txtarea, tagOpen, tagClose, sampleText) ->

    #  var txtarea;
    #  if (document.editform) {
    #    txtarea = document.editform.wpTextbox1;
    #  } else {
    #    var areas = document.getElementsByTagName("textarea");
    #    txtarea = areas[areas.length - 1];
    #  }
    checkSelectedText = ->
      unless selText
        selText = sampleText
        isSample = true
      else if selText.charAt(selText.length - 1) is " "
        selText = selText.substring(0, selText.length - 1)
        tagClose += " "
      return
    selText = undefined
    isSample = false
    if document.selection and document.selection.createRange
      if document.documentElement and document.documentElement.scrollTop
        winScroll = document.documentElement.scrollTop
      else winScroll = document.body.scrollTop  if document.body
      txtarea.focus()
      range = document.selection.createRange()
      selText = range.text
      checkSelectedText()
      range.text = tagOpen + selText + tagClose
      if isSample and range.moveStart
        tagClose = tagClose.replace(/\n/g, "")  if window.opera
        range.moveStart "character", -tagClose.length - selText.length
        range.moveEnd "character", -tagClose.length
      range.select()
      if document.documentElement and document.documentElement.scrollTop
        document.documentElement.scrollTop = winScroll
      else document.body.scrollTop = winScroll  if document.body
    else if txtarea.selectionStart or txtarea.selectionStart is "0" or txtarea.selectionStart is 0
      textScroll = txtarea.scrollTop
      txtarea.focus()
      startPos = txtarea.selectionStart
      endPos = txtarea.selectionEnd
      selText = txtarea.value.substring(startPos, endPos)
      checkSelectedText()
      txtarea.value = txtarea.value.substring(0, startPos) + tagOpen + selText + tagClose + txtarea.value.substring(endPos, txtarea.value.length)
      if isSample
        txtarea.selectionStart = startPos + tagOpen.length
        txtarea.selectionEnd = startPos + tagOpen.length + selText.length
      else
        txtarea.selectionStart = startPos + tagOpen.length + selText.length + tagClose.length
        txtarea.selectionEnd = txtarea.selectionStart
      txtarea.scrollTop = textScroll
    return
