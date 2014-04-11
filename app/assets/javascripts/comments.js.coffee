Quails.comments =
    init: ->

      form = $("#new_comment").clone()

      $(".main").on "click", ".reply a", ->
        new_form = form.clone()
        $("#comment_parent_id", new_form).val $(this).data("comment-id")
        new_form.attr("id", "reply" + $(this).data("comment-id")).insertAfter $(this).closest(".reply")
        false

      $(".main").on "ajax:success", "form.comment", (e, data) ->
        form_id = $(this).attr("id")
        new_comment = $(data)
        if form_id is "new_comment"
          $("#add_comment").before new_comment
          $(this).replaceWith form.clone()
        else
          parent = $(this).closest(".comment_box")
          subcomments = parent.next(".subcomments")
          if subcomments.length is 0
            parent.after $("<div></div>", class: "subcomments")
            subcomments = parent.next(".subcomments")
          subcomments.append new_comment
          $(this).detach()
        window.location.hash = new_comment.attr("id")
