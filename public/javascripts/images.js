$(function() {
	function refreshObservList() {
		if($('ul.current-obs li').length == 0) {
			$("<li>", {
				'class' : 'errors'
			}).html('None').prependTo("ul.current-obs");
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
		var date = $("input#q_observ_date_eq");  
		var loc = $("select#q_locus_id_eq");  
		var sp = $("select#q_species_id_eq");  
		var dataString = 	date.attr('name') + '=' + date.val() + "&" +
							loc.attr('name') + '=' + loc.val() + "&" +
							sp.attr('name') + '=' + sp.val();
		$.ajax({
			type : "GET",
			url : "/observations/search",
			data : dataString,
			success : function(data) {
				$('.found-obs li').remove();
				$(data).each(function() {
					$('<li>').append($('<div>').append($('<span>').html(this.sp_data), $('<span>').html(this.obs_data)))
						.appendTo($('.found-obs'));
				});
				$('.found-obs li').draggable({ revert: "invalid" });
			}
		});
		return false;
	});
	
	$('.observation_list').droppable({
				
	});
	
});
