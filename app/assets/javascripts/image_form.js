// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.custom
//= require suggest_over_combo

$(function () {

    var current_obs = $('.current-obs'),
        found_obs = $('.found-obs'),
        originalObservations = current_obs.html();

    function refreshObservList() {
        if ($('li', current_obs).length == 0) {
            $("<div>", {
                'class':'errors'
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
        var data = $.param($(".observation_search :input"));
        found_obs.load("/observations/search", data, function (data) {
            $('.observation_options').removeClass('loading');
            $('li', found_obs).draggable({ "revert":"invalid" });
        });
    }

    function insertNewObservation(newObs) {
        //newObs.draggable("destroy");
        newObs.attr('style', '').appendTo(current_obs);
        refreshObservList();
    }

    current_obs.on('click', '.remove', function () {
        $(this).closest('li').remove();
        refreshObservList();
    });

    $('.restore').on('click', function () {
        current_obs.html(originalObservations);
        refreshObservList();
    });

    // Search button click
    $('.obs_search_btn').click(searchForObservations);

    $('.observation_list').droppable({
        accept:'.found-obs li',
        drop:function (event, ui) {
            var first = $('li:first', current_obs),
                fdata = $('div:eq(1)', first).text().split(', ', 2).join(),
                newObs = ui.draggable,
                newdata = newObs.find('div:eq(1)').text().split(', ', 2).join();
            if (first.length == 0 || newdata == fdata) {
                insertNewObservation(newObs);
            }
            else {
                $('<div class="confirm" title="Overwrite observations?">')
                    .append($("<p>").text('You are trying to add an observation with different date/locus from ' +
                    'existing. Do you want to remove old observations and add a new one?'))
                    .dialog({
                        modal:true,
                        closeOnEscape:false,
                        open:function (event, ui) {
                            $(".ui-dialog-titlebar-close", ui.dialog).hide();
                        },
                        buttons:{
                            "Overwrite":function () {
                                $(this).dialog("close");
                                current_obs.empty();
                                insertNewObservation(newObs);
                            },
                            "Cancel":function () {
                                $(this).dialog("close");
                                var originalDrag = ui.helper.data('draggable');
                                // Revert mechanism taken from JQuery UI source
                                newObs.animate(originalDrag.originalPosition, parseInt(originalDrag.options.revertDuration, 10));
                            } }});
            }
        }
    });

    $('form.image').submit(function () {
        $('.observation_search').empty();
        found_obs.empty();
    });

    // Init

    refreshObservList();

});
