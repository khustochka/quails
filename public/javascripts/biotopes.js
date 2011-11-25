$(function () {

    var biotopes = $.makeArray($('#observation_biotope').children("option")
        .map(function () {
            if ($(this).text() != "") return $(this).val();
        }));

    $.widget("ui.biotope", {
        _create: function () {
            var self = this,
                select = this.element.hide(),
                selected = select.children(":selected"),
                value = ( selected.val() != null ) ? selected.text() : "";
            var input = this.input = $("<input type=\"text\">")
                .insertAfter(select)
                .val(value)
                .addClass('string short')
                .attr('id', select.attr('id'))
                .attr('name', select.attr('name'))
                .attr('required', select.attr('required'))
                .autocomplete({
                    autoFocus: true,
                    source: biotopes,
                    minLength: 0,
                    change: function (event, ui) {
                        if (!ui.item) {
                            var val = $(this).val();
                            if ($.inArray(val, biotopes) < 0) biotopes.push(val);
                            $("#observation_biotope", '.obs-row').autocomplete("option", "source", biotopes);
                        }
                    }
                });
            select.detach();
            this.button = $("<button type='button'>&nbsp;</button>")
                .attr("tabIndex", -1)
                .attr("title", "Show All Items")
                .insertAfter(input)
                .button({
                    icons:{
                        primary:"ui-icon-triangle-1-s"
                    },
                    text:false
                })
                .removeClass("ui-corner-all")
                .addClass("ui-corner-right ui-button-icon")
                .click(function () {
                    // close if already visible
                    if (input.autocomplete("widget").is(":visible")) {
                        input.autocomplete("close");
                        return;
                    }
                    // pass empty string as value to search for, displaying all results
                    input.autocomplete("search", "");
                    input.focus();
                });
        }
    });
});