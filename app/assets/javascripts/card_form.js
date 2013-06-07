//= require jquery_ujs
//= require jquery-ui.custom
//= require suggest_over_combo


$(function () {

  var sample_row_html = $('.obs-row:last')[0].outerHTML,
      last_row_num = $('.obs-row').length - 1,
      template_row_num = last_row_num,
      tmpl_regex = new RegExp("(_|\\[)" + template_row_num + "(_|\\])", "g"),
      options_list = $('.obs-row:last select.sp-suggest').children("option");

  $('.obs-row:last').remove();

  function addNewRow() {
    last_row_num++;
    var row_html = sample_row_html.replace(tmpl_regex, "$1" + last_row_num + "$2");
    $(row_html).insertBefore($('.fixed-bottom'));
    $('.obs-row:last .sp-suggest').combobox();
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

  $('.sp-suggest').combobox();

//  if (typeof sp_list !== undefined) {
//    $('.sp-light').autocomplete({
//      source: sp_list,
//      minLength: 3,
//      select: function (event, ui) {
//        //$( "#project" ).val( ui.item.label );
//        //$( "#project-id" ).val( ui.item.value );
//        return false;
//      }});
//  }

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


  $('#species-quick-add')
    // don't navigate away from the field on tab when selecting an item
      .bind("keydown", function (event) {
        if (event.keyCode === $.ui.keyCode.TAB &&
            $(this).data("ui-autocomplete").menu.active) {
          event.preventDefault();
        }
      })
      .autocomplete({
        delay: 0,
        minLength: 3,
        autoFocus: true,
        source: function (request, response) {
          var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
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
      }).data("ui-autocomplete")._renderItem = function (ul, item) {
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

});
