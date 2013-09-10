// Tag insertion
$(function () {
  var textarea = $('.wiki_field')[0],
      sp_insert_button = $("<button>", {text: "[species]", id: "insert_sp_tag", type: "button"});

  // Add a button

  $("<div>", {class: "edit_tools"}).insertBefore(textarea);

  sp_insert_button.click(function () {
    insertTags(textarea, '{{', '|}}', 'вид');
  });

  sp_insert_button.appendTo(".edit_tools");

});

function insertTags(txtarea, tagOpen, tagClose, sampleText) {
//  var txtarea;
//  if (document.editform) {
//    txtarea = document.editform.wpTextbox1;
//  } else {
//    var areas = document.getElementsByTagName("textarea");
//    txtarea = areas[areas.length - 1];
//  }
  var selText, isSample = false;
  if (document.selection && document.selection.createRange) {
    if (document.documentElement && document.documentElement.scrollTop) {
      var winScroll = document.documentElement.scrollTop;
    } else if (document.body) {
      var winScroll = document.body.scrollTop;
    }
    txtarea.focus();
    var range = document.selection.createRange();
    selText = range.text;
    checkSelectedText();
    range.text = tagOpen + selText + tagClose;
    if (isSample && range.moveStart) {
      if (window.opera) {
        tagClose = tagClose.replace(/\n/g, "");
      }
      range.moveStart("character", -tagClose.length - selText.length);
      range.moveEnd("character", -tagClose.length);
    }
    range.select();
    if (document.documentElement && document.documentElement.scrollTop) {
      document.documentElement.scrollTop = winScroll;
    } else if (document.body) {
      document.body.scrollTop = winScroll;
    }
  } else if (txtarea.selectionStart || txtarea.selectionStart == "0") {
    var textScroll = txtarea.scrollTop;
    txtarea.focus();
    var startPos = txtarea.selectionStart;
    var endPos = txtarea.selectionEnd;
    selText = txtarea.value.substring(startPos, endPos);
    checkSelectedText();
    txtarea.value = txtarea.value.substring(0, startPos) + tagOpen + selText + tagClose + txtarea.value.substring(endPos, txtarea.value.length);
    if (isSample) {
      txtarea.selectionStart = startPos + tagOpen.length;
      txtarea.selectionEnd = startPos + tagOpen.length + selText.length;
    } else {
      txtarea.selectionStart = startPos + tagOpen.length + selText.length + tagClose.length;
      txtarea.selectionEnd = txtarea.selectionStart;
    }
    txtarea.scrollTop = textScroll;
  }

  function checkSelectedText() {
    if (!selText) {
      selText = sampleText;
      isSample = true;
    } else if (selText.charAt(selText.length - 1) == " ") {
      selText = selText.substring(0, selText.length - 1);
      tagClose += " ";
    }
  }

}
