Quails.pages.comments = {
  init: function () {
    var form;
    form = $("#new_comment").clone();
    $(".main").on("click", ".reply a", function () {
      var new_form;
      new_form = form.clone();
      $("#comment_parent_id", new_form).val($(this).data("comment-id"));
      new_form.attr("id", "reply" + $(this).data("comment-id")).insertAfter($(this).closest(".reply"));
      return false;
    });
    $(".main").on("ajax:before", "form.comment", function (e, data) {
      $("p.errors").remove();
    });
    $(".main").on("ajax:success", "form.comment", function (e, data) {
      var form_id, new_comment, parent, subcomments;
      form_id = $(this).attr("id");
      new_comment = $(data);
      if (form_id === "new_comment") {
        $("#add_comment").before(new_comment);
        $(this).replaceWith(form.clone());
      } else {
        parent = $(this).closest(".comment_box");
        subcomments = parent.next(".subcomments");
        if (subcomments.length === 0) {
          parent.after($("<div></div>", {
            "class": "subcomments"
          }));
          subcomments = parent.next(".subcomments");
        }
        subcomments.append(new_comment);
        $(this).detach();
      }
      return window.location.hash = new_comment.attr("id");
    });
    return $(".main").on("ajax:error", "form.comment", function (e, xhr, status, error) {
      if (xhr.status === 422) {
        $(this).before($("<p>", {
          "class": "errors",
          text: xhr.responseText
        }));
      } else {
        $(this).before($("<p>", {
          "class": "errors",
          text: "Извините, произошла ошибка."
        }));
      }
    });
  }
};
