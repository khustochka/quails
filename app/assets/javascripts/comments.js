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

$(function () {
  var form = $('#new_comment').clone();

  $('.main').on('click', '.reply a', function () {
    var new_form = form.clone();
    $("#comment_parent_id", new_form).val($(this).data('comment-id'));
    new_form.attr('id', 'reply' + $(this).data('comment-id')).insertAfter($(this).closest(".reply"));
    return false;
  });

  $('.main').on('ajax:success', 'form', function (e, data) {
    var form_id = $(this).attr("id"),
        new_comment = $(data);
    if (form_id == "new_comment") {
      $("#add_comment").prev().after(new_comment);
      $(this).replaceWith(form);
    }
    else {
      var parent = $(this).closest(".comment_box");
      var subcomments = parent.next('.subcomments');
      if (subcomments.length == 0) {
        parent.after($("<div></div>", {class: "subcomments"}));
        subcomments = parent.next('.subcomments');
      }
      subcomments.append(new_comment);
      $(this).detach();
    }
    window.location.hash = new_comment.attr("id");
  })

});
