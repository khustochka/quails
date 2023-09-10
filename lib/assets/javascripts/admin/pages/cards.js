//= require jquery-ui.addon
//= require suggest_over_combo
//= require card_observ_form_shared

Quails.pages.cards = {
  init: function () {
    this.initObservationRows();
    this.initDatepicker();
    this.initLocusAutocomplete();
    this.initAddRows();
    this.initRemoveAndDestroy();
    this.initFastSpeciesLinks();
    this.initQuickAdd();
    this.initTaxaAutosuggest();
    this.initMarkAsVoice();
    return this.initExtractorAndMover();
  },
  initObservationRows: function () {
    this.last_row_num = $('.obs-row').length - 1;
    this.sample_row_html = $('.obs-row:last')[0].outerHTML;
    this.tmpl_regex = new RegExp("(_|\\[)" + this.last_row_num + "(_|\\])", "g");
    return $('.obs-row:last').remove();
  },
  initDatepicker: function () {
    var currentDate, datefield;
    datefield = $('#card_observ_date');
    currentDate = datefield.val();
    datefield.attr('type', 'hidden');
    datefield.parent().hide();
    $('<div class=\'inline_date\'></div>').prependTo('form.simple_form');
    return $('.inline_date').datepicker({
      dateFormat: 'yy-mm-dd',
      firstDay: 1,
      altField: datefield,
      altFormat: 'yy-mm-dd',
      defaultDate: currentDate
    });
  },
  initLocusAutocomplete: function () {
    $("select#card_locus_id").combobox();
    $('input#card_locus_id').prop('required', true);
    return $('.fast_locus').click(function () {
      $("input#card_locus_id").data('ui-autocomplete').search(this.textContent);
      return $(".ui-menu-item a:contains(" + this.textContent + "):first").click();
    });
  },
  initAddRows: function () {
    return $('#add-row').click((function (_this) {
      return function () {
        _this.addNewRow();
        return window.scrollTo(0, $(document).height());
      };
    })(this));
  },
  initRemoveAndDestroy: function () {
    $('form.simple_form').on('click', '.remove', function () {
      $(this).closest('.obs-row').remove();
    });
    return $('a.destroy').data('remote', 'true').on('ajax:success', function () {
      var row;
      row = $(this).closest('.obs-row');
      row.next().remove();
      row.remove();
    }).on('ajax:error', function () {
      alert('Error removing observation');
    });
  },
  initFastSpeciesLinks: function () {
    var global;
    global = this;
    return $('.fast-sp-link').click(function () {
      var row;
      row = global.addNewRow();
      $('.sp-light', row).val($(this).data('label'));
      $('.sp-light', row).next().val($(this).data('taxon-id'));
      return false;
    });
  },
  initQuickAdd: function () {
    this.initTaxonSuggestField('#species-quick-add', (function (_this) {
      return function (event, ui) {
        var row;
        row = _this.addNewRow();
        $('.sp-light', row).val(ui.item.value);
        $('.sp-light', row).next().val(ui.item.id);
        $('#species-quick-add').val('');
        window.scrollTo(0, $(document).height());
        return false;
      };
    })(this));
    return this.preventSubmitOnEnter();
  },
  preventSubmitOnEnter: function () {
    return $('#species-quick-add').keydown(function (event) {
      if (event.keyCode === 13 && !event.ctrlKey) {
        event.preventDefault();
        return false;
      } else if (event.keyCode === 13 && event.ctrlKey) {
        $('.simple_form').submit();
      }
    });
  },
  initExtractorAndMover: function () {
    $('.extractor').click(function (e) {
      window.location.href = $('.extractor').attr('href') + '?' + $('input[name="obs[]"]:checked').serialize();
      e.preventDefault();
    });
    return $('.mover').click(function (e) {
      window.location.href = $('.mover').attr('href') + '?' + $('input[name="obs[]"]:checked').serialize();
      e.preventDefault();
    });
  },
  initMarkAsVoice: function () {
    var keypress;
    keypress = new window.keypress.Listener;
    return keypress.simple_combo('alt v', function () {
      var checkbox, focused, row;
      checkbox = void 0;
      focused = $(':focus');
      row = focused.closest('.obs-row');
      if (row.length === 0 && focused.attr('id') === 'species-quick-add') {
        row = $('.obs-row:last');
      }
      checkbox = $('div.card_observations_voice input.boolean', row);
      checkbox.prop('checked', !checkbox.prop('checked'));
    });
  },
  initTaxaAutosuggest: function () {
    return this.initTaxonSuggestField(".sp-light");
  },
  addNewRow: function () {
    var row_html;
    this.last_row_num++;
    row_html = this.sample_row_html.replace(this.tmpl_regex, '$1' + this.last_row_num + '$2');
    $(row_html).appendTo($('.obs-block'));
    this.initTaxonSuggestField('.obs-row:last .sp-light');
    return $('.obs-row:last');
  },
  initTaxonSuggestField: Quails.features.taxaAutosuggest.initTaxonSuggestField
};
