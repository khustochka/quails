$(function() {
	function refreshObservList() {
		if($('ul.current-obs li').length == 0) {
			$("<div>", {
				'class' : 'errors'
			}).text('None').prependTo("ul.current-obs");
			$('.buttons input:submit').prop('disabled', true);
		}
	}

	refreshObservList();

	$("#image_code").keyup(function() {
		$("img.image_pic").attr('src', $("img.image_pic").attr('src').replace(/\/tn_[^\.\/]*/, "/tn_" + $(this).val()));
	});

	$('.remove').live('click', function() {
		$(this).closest('li').remove();
		refreshObservList();
	});
	
	// Search button click
	$('.search_btn').click(function(e) {
		var arr = new Array($("input#q_observ_date_eq"), $("select#q_locus_id_eq"), $("select#q_species_id_eq"));
		var dataString = $.param($.map(arr, function(el) {
			return {"name": el.attr('name'), 'value': el.val()};
		})); 
		$.ajax({
			type : "GET",
			url : "/observations/search",
			data : dataString,
			success : function(data) {
				$('.found-obs li').remove();
				$(data).each(function() {
					$("<li class='new-obs'>").data('ob_id', this.id).append($('<div>').append($('<span>').html(this.sp_data), $('<span>').html(this.obs_data)))
						.appendTo($('.found-obs'));
				});
				$('.found-obs li').draggable({ revert: "invalid" });
			}
		});
		return false;
	});
	
	$('.observation_list').droppable({
		drop: function(event, ui) {
			var el = ui.draggable;
			el.draggable("disable");
			$('.current-obs > div').remove();
			var removeIcon = $("<span class='pseudolink remove'>").html($("<img>").attr('src', '/images/x_alt_16x16.png'));
			var hiddenField = $("<input type='hidden' name='image[observation_ids][]' value='"+ el.data('ob_id') + "'>");
			$("<li class='new-obs'>").html(el.html()).prepend(hiddenField).append(removeIcon).appendTo('.current-obs');
			el.remove();
			$('.buttons input:submit').prop('disabled', false);
		}
	});
	
});
