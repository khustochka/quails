//= require jquery-ui.addon
//= require suggest_over_combo
//= require wiki_form
//= require keypress


$(function () {

  var sample_row_html = $('.obs-row:last')[0].outerHTML,
      last_row_num = $('.obs-row').length - 1,
      template_row_num = last_row_num,
      tmpl_regex = new RegExp("(_|\\[)" + template_row_num + "(_|\\])", "g"),
      lightmode = (typeof sp_list !== 'undefined'),
      options_list = $('.obs-row:last select.sp-suggest').children("option");

  $('.obs-row:last').remove();

  function light_autocomplete(el) {
    if ($(el).length > 0) $(el).autocomplete({
      delay: 0,
      autoFocus: true,
      source: sp_list,
      minLength: 2,
      select: function (event, ui) {
        $(this).val(ui.item.value);
        $(this).next().val(ui.item.id);
        return false;
      }
    });
  }

  function initAutocomplete(parent) {
    if (lightmode) light_autocomplete(parent + ' .sp-light');
    else $(parent + ' .sp-suggest').combobox();
  }

  function addNewRow() {
    last_row_num++;
    var row_html = sample_row_html.replace(tmpl_regex, "$1" + last_row_num + "$2");
    $(row_html).insertBefore($('.fixed-bottom'));
    initAutocomplete(".obs-row:last");
    $('.obs-row:last .patch-suggest').combobox();
    window.scrollTo(0, $(document).height());
    return $('.obs-row:last');
  }

  function firstEmptyRow() {
    return addNewRow();
  }

  function quickAddSpecies(speciesName) {
    var firstEmpty = firstEmptyRow(),
        suggest = $('.sp-suggest', firstEmpty);

    suggest.children("option").each(function () {
      if ($(this).text() == speciesName) {
        this.selected = true;
        $('.ui-autocomplete-input', firstEmpty).val(speciesName);
        return false;
      }
    });
  }

  $('#add-row').click(addNewRow);

  $('form.simple_form').on('click', '.remove', function () {
    $(this).closest('.obs-row').remove();
  });

  initAutocomplete("");

  $('.patch-suggest').combobox();

  $('a.destroy')
      .data('remote', 'true')
      .on('ajax:success', function () {
        $(this).closest('.obs-row').remove();
      })
      .on('ajax:error', function () {
        alert("Error removing observation");
      });

  // Mark autocomplete locus field as required
  $('input#card_locus_id').prop('required', true);

  // datepicker

  var datefield = $("#card_observ_date"),
      currentDate = datefield.val();
  datefield.attr("type", "hidden");
  datefield.parent().hide();

  $("<div class='inline_date'></div>").prependTo("form.simple_form");
  $(".inline_date").datepicker({
    dateFormat: "yy-mm-dd",
    firstDay: 1, // To start a week from Monday
    altField: datefield,
    altFormat: "yy-mm-dd",
    defaultDate: currentDate
  });

  // Quick add

  if (lightmode) $('#species-quick-add').autocomplete({
    delay: 0,
    autoFocus: true,
    source: function (request, response) {
      var matcher = new RegExp("(^| )" + $.ui.autocomplete.escapeRegex(request.term), "i");
      response($.map(sp_list, function (species) {
        var text = species.value;
        if (( species.value != null ) && ( !request.term || matcher.test(text) ))
          return {
            label: text.replace('Avis incognita', '<i>Avis incognita</i>').replace(
                new RegExp(
                    "(?![^&;]+;)(?!<[^<>]*)(" +
                        $.ui.autocomplete.escapeRegex(request.term) +
                        ")(?![^<>]*>)(?![^&;]+;)", "gi"
                ), "<strong>$1</strong>"),
            value: text
          };
      }));
    },
    minLength: 2,
    select: function (event, ui) {
      var row = firstEmptyRow();
      $('.sp-light', row).val(ui.item.value);
      $('.sp-light', row).next().val(ui.item.id);
      $(this).val("");
      return false;
    }
  });
  else $('#species-quick-add')
    // don't navigate away from the field on tab when selecting an item
      .bind("keydown", function (event) {
        if (event.keyCode === $.ui.keyCode.TAB &&
            $(this).data("ui-autocomplete").menu.active) {
          event.preventDefault();
        }
      })
      .autocomplete({
        delay: 0,
        minLength: 2,
        autoFocus: true,
        source: function (request, response) {
          var matcher = new RegExp("(^| )" + $.ui.autocomplete.escapeRegex(request.term), "i");
          response(options_list.map(function () {
            var text = $(this).text();
            if (( this.value != null ) && ( !request.term || matcher.test(text) ))
              return {
                label: text.replace('Avis incognita', '<i>Avis incognita</i>').replace(
                    new RegExp(
                        "(?![^&;]+;)(?!<[^<>]*)(" +
                            $.ui.autocomplete.escapeRegex(request.term) +
                            ")(?![^<>]*>)(?![^&;]+;)", "gi"
                    ), "<strong>$1</strong>"),
                value: text
              };
          }));
        },
        select: function (event, ui) {
          quickAddSpecies(ui.item.value);
          $(this).val("");
          return false;
        }
      });

  $('#species-quick-add').data("ui-autocomplete")._renderItem = function (ul, item) {
    return $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a>" + item.label + "</a>")
        .appendTo(ul);
  };

  // Extract and move to the new card
  $(".extractor").click(function (e) {
    window.location.href = $(".extractor").attr('href') + "?" + $('input[name="obs[]"]:checked').serialize();
    e.preventDefault();
  });

  $(".mover").click(function (e) {
    window.location.href = $(".mover").attr('href') + "?" + $('input[name="obs[]"]:checked').serialize();
    e.preventDefault();
  });

  // Prevent submit on Enter

  $('#species-quick-add').keydown(function (event) {
    if (event.keyCode == 13 && !event.ctrlKey) {
      event.preventDefault();
      return false;
    }
    else if (event.keyCode == 13 && event.ctrlKey) {
      $('.simple_form').submit();
    }
  });

  // Alt+V to mark as voice
  keypress.combo("alt v", function () {
    var checkbox,
        focused = $(':focus'),
        row = focused.closest('.obs-row');

    if (row.length == 0 && focused.attr("id") == 'species-quick-add') row = $('.obs-row:last')
    checkbox = $("div.card_observations_voice input.boolean", row)
    checkbox.prop("checked", !checkbox.prop("checked"));
  });

});
