
(function( $ ) {
    function filterWithMatcher(select, request, matcher, excludeMatcher) {
        return select.children( "option" ).map(function() {
            var text = $( this ).text();
            if ( ( this.value != null ) && (
                // Exclude those matching another matcher if it ts passed
                !request.term || (matcher.test(text) && (excludeMatcher ? !excludeMatcher.test(text) : true)) )
                )
                return {
                    label: text.replace(
                        new RegExp(
                            "(?![^&;]+;)(?!<[^<>]*)(" +
                            $.ui.autocomplete.escapeRegex(request.term) +
                            ")(?![^<>]*>)(?![^&;]+;)", "gi"
                        ), "<strong>$1</strong>" ),
                    value: text,
                    option: this
                };
        })
    }

    $.widget( "ui.combobox", {
        _create: function() {
            var self = this,
                select = this.element.hide(),
                selected = select.children( ":selected" ),
                value = ( selected.val() != null ) ? selected.text() : "";
            var input = this.input = $( "<input type=\"text\">" )
                .insertAfter( select )
                .val( value )
                .attr('id', select.attr('id'))
                .autocomplete({
                    delay: 0,
                    minLength: (select.children( "option" ).length > 150) ? 2 : 1,
                    autoFocus: true,
                    source: function( request, response ) {
                        var matcher1 = new RegExp( "^" + $.ui.autocomplete.escapeRegex(request.term), "i" ),
                            matcher2 = new RegExp( "( |-|\/)" + $.ui.autocomplete.escapeRegex(request.term), "i" ),
                        results1, results2;
                        results1 = filterWithMatcher(select, request, matcher1);
                        // Exlude those matching the first matcher
                        results2 = filterWithMatcher(select, request, matcher2, matcher1);
                        response( results1.add(results2) );
                    },
                    select: function( event, ui ) {
                        ui.item.option.selected = true;
                        self._trigger( "selected", event, {
                            item: ui.item.option
                        });
                    },
                    change: function( event, ui ) {
                        if ( !ui.item ) {
                            var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
                                valid = false;
                            select.children( "option" ).each(function() {
                                if ( $( this ).text().match( matcher ) ) {
                                    this.selected = valid = true;
                                    return false;
                                }
                            });
                            if ( !valid ) {
                                // remove invalid value, as it didn't match anything
                                $( this ).val( "" );
                                select.val( "" );
                                input.data( "ui-autocomplete" ).term = "";
                                return false;
                            }
                        }
                    }
                })
                /*.addClass( "ui-widget ui-widget-content ui-corner-left" )*/;

            input.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
                return $( "<li></li>" )
                    .data( "ui-autocomplete-item", item )
                    .append( "<a>" + item.label + "</a>" )
                    .appendTo( ul );
            };

        /*    this.button = $( "<button type='button'>&nbsp;</button>" )
                .attr( "tabIndex", -1 )
                .attr( "title", "Show All Items" )
                .insertAfter( input )
                .button({
                    icons: {
                        primary: "ui-icon-triangle-1-s"
                    },
                    text: false
                })
                .removeClass( "ui-corner-all" )
                .addClass( "ui-corner-right ui-button-icon" )
                .click(function() {
                    // close if already visible
                    if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
                        input.autocomplete( "close" );
                        return;
                    }

                    // pass empty string as value to search for, displaying all results
                    input.autocomplete( "search", "" );
                    input.focus();
                });*/
        },

        destroy: function() {
            this.input.remove();
            //this.button.remove();
            this.element.show();
            $.Widget.prototype.destroy.call( this );
        }
    });
})( jQuery );


// exact text selector
//$.expr[":"].econtains = function(obj, index, meta, stack){
//    return (obj.textContent || obj.innerText || $(obj).text() || "").toLowerCase() == meta[3].toLowerCase();
//};
