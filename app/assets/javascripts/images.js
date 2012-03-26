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
//= require jquery-ui-1.8.18.custom.min
//= require suggest_over_combo

$(function () {

    var current_obs = $('.current-obs'),
        found_obs = $('.found-obs');

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
        var data = $(".observation_search :input").serializeArray();
        $.get("/observations/search", data, function (data) {
            $('.observation_options').removeClass('loading');
            buildObservations(data, found_obs, true);
            $('li', found_obs).draggable({ "revert":"invalid" });
        });
    }

    function buildObservations(data, ulSelector, newObs) {
        $(data).each(function () {
            var hiddenField = $("<input type='hidden' name='obs[]'>").val(this.id),
                removeIcon = $("<span class='remove'>").html($("<img>").attr('src', '/img/x_14x14.png'));
            $("<li>", newObs ? { "class":'new-obs'} : null)
                .append(hiddenField, removeIcon,
                $('<div>').html(this.species_str),
                $('<div>').html(this.when_where_str)
            )
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
        //newObs.draggable("destroy");
        newObs.attr('style', '').appendTo(current_obs);
        refreshObservList();
    }

    $("#image_code").keyup(function () {
        $("img.image_pic").attr('src', $("img.image_pic").attr('src').replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
    });

    current_obs.on('click', '.remove', function () {
        $(this).closest('li').remove();
        refreshObservList();
    });

    $('.restore').on('ajax:beforeSend', function () {
        current_obs.empty();
        $('.observation_list').addClass('loading');
    });

    $('.restore').on('ajax:success', function (xhr, data, status) {
        $('.observation_list').removeClass('loading');
        buildObservations(data, current_obs, false);
        refreshObservList();
    });

    // Search button click
    $('.obs_search_btn').click(searchForObservations);

    // Onchange works bad on text input and doesn't work on autosuggest
    // $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq").bind('change', searchForObservations);

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
        $('.flickr_search').empty();
        found_obs.empty();
    });

    // Flickr functions

    function searchOnFlickr() {
        //found_obs.empty();
        //$('.observation_options').addClass('loading');
        var data = $(".flickr_search :input").serializeArray();
        $.get("/images/flickr_search", data, function (data) {
            $(data).each(function () {
                $("<img>", { "src":this.url_s }).appendTo('.flickr_search');
            });
        });
    }

    // Search button click
    $('.flickr_search_btn').click(searchOnFlickr);

    // Init

    refreshObservList();

});
