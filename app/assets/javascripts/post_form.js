//= require jquery_ujs
//= require suggest_over_combo

// Tag insertion
$(function () {
  var textarea = $('#post_text'),
      sp_insert_button = $("<button>", {text: "[species]", id: "insert_sp_tag", type: "button"});

  // Add a button

  $("<div>", {class: "edit_tools"}).insertBefore(textarea);

  sp_insert_button.click(function () {
    insertTags('[', '|]', 'вид');
  });

  sp_insert_button.appendTo(".edit_tools");


  // Observations search form

  var searchForm = $('form.search');

  searchForm.attr('action', "/observations/bulk");
  $("#new_post_id").appendTo(searchForm);

});

// Lj post
$(function () {
  var lj_post_form = $('form#lj_post');
  lj_post_form.data('remote', true);
  lj_post_form.attr('action', lj_post_form.attr('action') + '.json');

  lj_post_form.bind('ajax:beforeSend', function () {
    $("li#lj_url_li").append("<img src='/img/loading_small.gif' id='spinner'>");
  });

  lj_post_form.bind("ajax:error", function (e, xhr) {
    $('#spinner').remove();
    alert($.parseJSON(xhr.responseText).alert);
  });

  lj_post_form.bind("ajax:success", function (e, data) {
    var url = data.url;
    $("li#lj_url_li").html($("<a>", {text: url, href: url}));
  });
});

function insertTags(tagOpen, tagClose, sampleText) {
  var txtarea;
  if (document.editform) {
    txtarea = document.editform.wpTextbox1;
  } else {
    var areas = document.getElementsByTagName("textarea");
    txtarea = areas[areas.length - 1];
  }
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
