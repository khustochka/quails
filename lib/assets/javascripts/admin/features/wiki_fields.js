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

    sp_insert_button.click(this.spInsertAction(this, textarea));

    img_insert_button.click(this.imgInsertAction(this, textarea));

    video_insert_button.click(this.videoInsertAction(this, textarea));

    post_insert_button.click(this.postInsertAction(this, textarea));

    var keypress = new (window.keypress.Listener);

    keypress.simple_combo('alt s', this.spInsertAction(this, textarea));

    // alt+i on mac cannot be overriden
    //keypress.simple_combo('alt i', this.imgInsertAction(this, textarea));

    // on the cards page conflicts with Voice shortcut:
    //keypress.simple_combo('alt v', this.videoInsertAction(this, textarea));

    keypress.simple_combo('alt p', this.postInsertAction(this, textarea));

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

  closeSpeciesDialog: function (_this) {
    $(".species_wiki_input").val("");
    $(".species_wiki_input").autocomplete( "close" );
    $(".insert_species_dialog").hide();
  },

  openSpeciesSearch: function (_this, textarea) {
    var dialog = $(".insert_species_dialog");
    if ($(dialog).length === 0) {
      dialog = $("<div class=\"insert_species_dialog ui-front\">")
        .append($("<input class='species_wiki_input'>"))
        .appendTo("body");

      $("input", dialog).on("blur", function() {
        _this.closeSpeciesDialog();
        textarea.focus();
      });

      $("input", dialog).on("keydown", function(event) {
        if (event.keyCode === $.ui.keyCode.ESCAPE) {
          _this.closeSpeciesDialog();
          textarea.focus();
        }
      });

      $(".species_wiki_input").autocomplete({
          source: "/species/admin/search.json",
          //appendTo: "body",
          select: function (event, ui) {
            if (ui.item.value) {
              _this.closeSpeciesDialog();
              _this.insertTags(textarea, "{{", "|" + ui.item.value + "}}", ui.item.name);
            }
            return false;
          },
          delay: 0,
          autoFocus: true,
          minLength: 2
        });

        $(".species_wiki_input").data("ui-autocomplete")._renderItem = function (ul, item) {
              return $("<li></li>")
                  .data("ui-autocomplete-item", item)
                  .append(
                      $('<a>' + item.name + ' </a>')
                          .append('<i class="sci_name">' + item.label + "</i>")
                  )
                  .appendTo(ul);
            };
    } else dialog.show();
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
  },

  spInsertAction: function (_this, textarea) {
    return function () {
      //_this.insertTags(textarea, "{{", "|}}", "вид");
      _this.openSpeciesSearch(_this, textarea);
    };
  },

  imgInsertAction: function (_this, textarea) {
    return function () {
      _this.insertTags(textarea, "{{^", "}}", "image");
    };
  },

  videoInsertAction: function (_this, textarea) {
    return function () {
      _this.insertTags(textarea, "{{&", "}}", "video");
    };
  },

  postInsertAction:function (_this, textarea) {
    return function () {
      _this.insertTags(textarea, "{{#", "|}}", "post");
    };
  }

};
