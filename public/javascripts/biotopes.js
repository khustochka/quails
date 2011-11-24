$(function () {

    var biotopes = $.makeArray( $('#observation_biotope').children( "option" )
            .map( function() {
                if ($(this).text() != "") return $( this ).val();
        } ) );

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
                    source: biotopes
                });
            select.detach();
        }
    });

    $('#observation_biotope').biotope();
});