$(function() {

    var current_obs = $('.current-obs'),
        found_obs = $('.found-obs');

    function refreshObservList() {
        if ($('li', current_obs).length == 0) {
            $("<div>", {
                'class' : 'errors'
            }).text('None').appendTo(".observation_list");
            $('.buttons input:submit').prop('disabled', true);
        }
        else {
            $('.observation_list > div').remove();
            $('.buttons input:submit').prop('disabled', false);
        }
    }

    function searchForObservations() {
        found_obs.empty();
        $('.observation_options').addClass('loading');
        var data = $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq").serializeArray();
        $.ajax({
            type : "GET",
            url : "/observations/search",
            data : data,
            success : function(data) {
                $('.observation_options').removeClass('loading');
                buildObservations(data, found_obs, true);
                $('li', found_obs).draggable({ "revert" : "invalid" });
            }
        });
    }

    function buildObservations(data, ulSelector, newObs) {
        $(data).each(function() {
            var hiddenField = $("<input type='hidden' name='obs[]' value='" + this.id + "'>"),
                removeIcon = $("<span class='remove'>").html($("<img>").attr('src', '/images/x_alt_16x16.png'));
            $("<li>", newObs ? { "class": 'new-obs'} : null)
                .append(hiddenField)
                .append($('<span>').append(
                    $('<div>').html(this.sp_data),
                    $('<div>').html(this.obs_data))
                )
                .append(removeIcon)
                .appendTo($(ulSelector));
        });
    }

//    function getOriginalObservations() {
//        if ($('.restore').length == 0 || $('ul.errors li').length > 0)
//            refreshObservList();
//        else
//            $('.restore').click();
//    }

	function insertNewObservation(newObs) {
        newObs.draggable("destroy").attr('style', '').appendTo(current_obs);
        refreshObservList();
	}

    $("#image_code").keyup(function() {
        $("img.image_pic").attr('src', $("img.image_pic").attr('src').replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
    });

    $('.remove').live('click', function() {
        $(this).closest('li').remove();
        refreshObservList();
    });

    $('.restore').click(function() {
        current_obs.empty();
        $('.observation_list').addClass('loading');
    });

    $('.restore').bind('ajax:success', function(xhr, data, status) {
        $('.observation_list').removeClass('loading');
        buildObservations(data, current_obs, false);
        refreshObservList();
    });

    // Search button click
    $('.search_btn').click(searchForObservations);

    // Onchange works bad on text input and doesn't work on autosuggest
    // $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq").bind('change', searchForObservations);

    $('.observation_list').droppable({
    	accept : '.found-obs li',
        drop : function(event, ui) {
            var first = $('li:first', current_obs),
                fdata = $('span:eq(1)', first).text().split(', ', 2).join(),
                newObs = ui.draggable,
                newdata = newObs.find('span:eq(1)').text().split(', ', 2).join();
            if (first.length == 0 || newdata == fdata) {
            	insertNewObservation(newObs);
            }
            else {
                $('<div class="confirm" title="Overwrite observations?">')
                    .append($("<p>").text('You are trying to add an observation with different date/locus from ' +
                    			'existing. Do you want to remove old observations and add a new one?'))
                    .dialog({
                        modal: true,
						closeOnEscape: false,
						open: function(event, ui) { $(".ui-dialog-titlebar-close", ui.dialog).hide(); },
                        buttons: {
                            "Overwrite": function() {
                                $(this).dialog("close");
                                current_obs.empty();
                                insertNewObservation(newObs);
                            },
                            "Cancel": function() {
                                $(this).dialog("close");
                                var originalDrag = ui.helper.data('draggable');
                                // Revert mechanism taken from JQuery UI source
                                newObs.animate(originalDrag.originalPosition, parseInt(originalDrag.options.revertDuration, 10));
                            } }});
            }
        }
    });

    $('form.image').submit(function() {
        $('.observation_search').empty();
        found_obs.empty();
    });

    refreshObservList();

});
