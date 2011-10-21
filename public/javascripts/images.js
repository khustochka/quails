$(function() {
	function refreshObservList() {
		if($('ul.current-obs li').length == 0) {
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
		$('.found-obs').empty();
		$('.observation_options').addClass('loading');
		var data = $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq").serializeArray();
		$.ajax({
			type : "GET",
			url : "/observations/search",
			data : data,
			success : function(data) {
				$('.observation_options').removeClass('loading');
				buildObservations(data, '.found-obs', true);
				$('.found-obs li').draggable({ "revert" : "invalid" });
			}
		});
	}

	function buildObservations(data, ulSelector, newObs) {
		$(data).each(function() {
			var hiddenField = $("<input type='hidden' name='image[observation_ids][]' value='" + this.id + "'>");
			var removeIcon = $("<span class='pseudolink remove'>").html($("<img>").attr('src', '/images/x_alt_16x16.png'));
			$("<li>", newObs ? { "class": 'new-obs'} : null)
				.append(hiddenField)
				.append($('<div>').append($('<span>').html(this.sp_data), 
						$('<span>').html(this.obs_data)))
				.append(removeIcon)
				.appendTo($(ulSelector));
				});	
	}
	
	function getOriginalObservations() {
		if ($('.restore').length == 0)
			refreshObservList();
		else
			$('.restore').click();
	}

	$("#image_code").keyup(function() {
		$("img.image_pic").attr('src', $("img.image_pic").attr('src').replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
	});

	$('.remove').live('click', function() {
		$(this).closest('li').remove();
		refreshObservList();
	});
	
	$('.restore').click(function() {
		$('.current-obs').empty();
		$('.observation_list').addClass('loading');
	});
	
	$('.restore').bind('ajax:success', function(xhr, data, status) {
		$('.observation_list').removeClass('loading');
  		buildObservations(data, '.current-obs', false);
  		refreshObservList();
	});
	
	// Search button click
	$('.search_btn').click(searchForObservations);

	// Onchange works bad on text input and doesn't work on autosuggest
	// $("input#q_observ_date_eq, select#q_locus_id_eq, select#q_species_id_eq").bind('change', searchForObservations);

	$('.observation_list').droppable({
		drop : function(event, ui) {
			var el = ui.draggable;
			el.draggable("disable");
			$("<li class='new-obs'>").html(el.html()).appendTo('.current-obs');
			el.remove();
			refreshObservList();
		}
	});
	
	$('form.image').submit(function() {
		$('.observation_search').empty();
		$('.found-obs').empty();
	});
	
	getOriginalObservations();

});
