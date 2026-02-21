//= require jquery-ui.addon
//= require suggest_over_combo

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
        window.scrollTo(0, document.body.scrollHeight);
      };
    })(this));
  },
  initRemoveAndDestroy: function () {
    $('form.simple_form').on('click', '.remove', function () {
      $(this).closest('.obs-row').remove();
    });
    $('a.destroy').attr('data-remote', 'true').attr('data-type', 'json');
    $(document).on('ajax:success', 'a.destroy', function () {
      var row = $(this).closest('.obs-row');
      row.next().remove();
      row.remove();
    });
    $(document).on('ajax:error', 'a.destroy', function () {
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
    var _this = this;
    this.initTaxonSuggestField('#species-quick-add', function (input, item) {
      var row = _this.addNewRow();
      $('.sp-light', row).val(item.value);
      $('.sp-light', row).next().val(item.id);
      input.value = '';
      window.scrollTo(0, document.body.scrollHeight);
    });
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
    var row = $(row_html).appendTo($('.obs-block'));
    this.initTaxonSuggestField(row.find('.sp-light')[0]);
    return $('.obs-row:last');
  },
  initTaxonSuggestField: function (elements, onSelect) {
    Quails.features.taxaAutosuggest.initTaxonSuggestField(elements, onSelect);
  }
};
