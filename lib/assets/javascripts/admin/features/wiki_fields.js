Quails.features.wikiFields = {
  init: function () {
    var img_insert_button, post_insert_button, sp_insert_button, textarea, video_insert_button;
    textarea = $(".wiki_field")[0];
    sp_insert_button = $("<button>", {
      text: "{{species}}",
      id: "insert_sp_tag",
      type: "button"
    });
    img_insert_button = $("<button>", {
      text: "{{^image}}",
      id: "insert_img_tag",
      type: "button"
    });
    video_insert_button = $("<button>", {
      text: "{{&video}}",
      id: "insert_video_tag",
      type: "button"
    });
    post_insert_button = $("<button>", {
      text: "{{#post}}",
      id: "insert_post_tag",
      type: "button"
    });

    $("<div>", {
      "class": "edit_tools"
    }).insertBefore(textarea);

    sp_insert_button.click((function (_this) {
      return function () {
        //_this.insertTags(textarea, "{{", "|}}", "вид");
        _this.openSpeciesSearch(_this, textarea);
      };
    })(this));
    img_insert_button.click((function (_this) {
      return function () {
        _this.insertTags(textarea, "{{^", "}}", "image");
      };
    })(this));
    video_insert_button.click((function (_this) {
      return function () {
        _this.insertTags(textarea, "{{&", "}}", "video");
      };
    })(this));
    post_insert_button.click((function (_this) {
      return function () {
        _this.insertTags(textarea, "{{#", "|}}", "post");
      };
    })(this));

    return $(".edit_tools").append(sp_insert_button).append(img_insert_button).append(video_insert_button).append(post_insert_button);
  },

  insertTags: function (txtarea, tagOpen, tagClose, sampleText) {
    var endPos, isSample, range, selText, startPos, textScroll, winScroll;

    function checkSelectedText() {
      if (!selText) {
        selText = sampleText;
        isSample = true;
      } else if (selText.charAt(selText.length - 1) === " ") {
        selText = selText.substring(0, selText.length - 1);
        tagClose += " ";
      }
    }

    selText = Quails.features.wikiFields.getSelectedText(txtarea);
    isSample = false;
    if (document.selection && document.selection.createRange) {
      if (document.documentElement && document.documentElement.scrollTop) {
        winScroll = document.documentElement.scrollTop;
      } else {
        if (document.body) {
          winScroll = document.body.scrollTop;
        }
      }
      txtarea.focus();
      range = document.selection.createRange();
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
      } else {
        if (document.body) {
          document.body.scrollTop = winScroll;
        }
      }
    } else if (txtarea.selectionStart || txtarea.selectionStart === "0" || txtarea.selectionStart === 0) {
      textScroll = txtarea.scrollTop;
      txtarea.focus();
      startPos = txtarea.selectionStart;
      endPos = txtarea.selectionEnd;
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
  },

  openSpeciesSearch: function (_this, textarea) {
    var dialog = $(".insert_species_dialog");
    if ($(dialog).length === 0) {
      dialog = $("<div class=\"insert_species_dialog ui-front\" title=\"Select species\">")
        .append($("<input class='species_wiki_input'>"))
        .dialog({
            modal: true
          }
        );
      $(".species_wiki_input").autocomplete({
          source: "/species/search.json",
          //appendTo: "body",
          select: function (event, ui) {
            if (ui.item.value)
              $(dialog).dialog("close");
            _this.insertTags(textarea, "{{", "|" + ui.item.value + "}}", ui.item.name);
            return false;
          },
          delay: 0,
          autoFocus: true,
          minLength: 2
        }
      );
    } else dialog.dialog("open");
    var selText = _this.getSelectedText(textarea);
    $(".species_wiki_input").val(selText).focus().autocomplete("search");
  },

  getSelectedText: function (txtarea) {
    var range, selText;
    if (document.selection && document.selection.createRange) {
      txtarea.focus();
      range = document.selection.createRange();
      selText = range.text;
    } else if (txtarea.selectionStart || txtarea.selectionStart === "0" || txtarea.selectionStart === 0) {
      txtarea.focus();
      var startPos = txtarea.selectionStart;
      var endPos = txtarea.selectionEnd;
      selText = txtarea.value.substring(startPos, endPos);
    }
    return selText;
  }

};



