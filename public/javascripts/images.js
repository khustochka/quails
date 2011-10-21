$(function() {
	function refreshObservList() {
		if($('ul.current-obs li').length == 0) {
			$("<div>", {
				'class' : 'errors'
			}).text('None').prependTo("ul.current-obs");
			$('.buttons input:submit').prop('disabled', true);
		}
		else {
			$('.current-obs > div').remove();
			$('.buttons input:submit').prop('disabled', false);
		}
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
			$('.restore').trigger('click');	
	}

	$("#image_code").keyup(function() {
		$("img.image_pic").attr('src', $("img.image_pic").attr('src').replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
	});

	$('.remove').live('click', function() {
		$(this).closest('li').remove();
		refreshObservList();
	});
	
	$('.restore').click(function() {
		$('.current-obs li').remove();
		$('.observation_list').addClass('loading');
	});
	
	$('.restore').bind('ajax:success', function(xhr, data, status) {
		$('.observation_list').removeClass('loading');
  		buildObservations(data, '.current-obs', false);
  		refreshObservList();
	});
	
	// Search button click
	$('.search_btn').click(function(e) {
		$('.found-obs li').remove();
		$('.observation_options').addClass('loading');
		var arr = new Array($("input#q_observ_date_eq"), $("select#q_locus_id_eq"), $("select#q_species_id_eq"));
		var dataString = $.param($.map(arr, function(el) {
			return {
				"name" : el.attr('name'),
				'value' : el.val()
			};
		}));
		$.ajax({
			type : "GET",
			url : "/observations/search",
			data : dataString,
			success : function(data) {
				$('.observation_options').removeClass('loading');
				buildObservations(data, '.found-obs', true);				
				$('.found-obs li').draggable({ "revert" : "invalid" });
			}
		});
		return false;
	});

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
		$('.found-obs li').remove();
	});
	
	getOriginalObservations();

});
