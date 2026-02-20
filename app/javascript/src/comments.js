let form;

function initReplyLinks() {
  document.querySelector(".main").addEventListener("click", function (e) {
    const replyLink = e.target.closest(".reply a");
    if (!replyLink) return;
    e.preventDefault();
    const commentId = replyLink.dataset.commentId;
    const newForm = form.cloneNode(true);
    newForm.querySelector("#comment_parent_id").value = commentId;
    newForm.id = "reply" + commentId;
    delete newForm.dataset.commentForm;
    replyLink.closest(".reply").after(newForm);
  });
}

function initCommentForms() {
  const $ = window.$;

  $(".main").on("ajax:before", "form.comment", function () {
    $("p.errors", this).remove();
  });

  $(".main").on("ajax:success", "form.comment", function (_e, data) {
    const formEl = this;
    const newComment = $(data)[0];
    if ("commentForm" in formEl.dataset) {
      document.getElementById("add_comment").before(newComment);
      $(formEl).replaceWith(form.cloneNode(true));
    } else {
      const parent = formEl.closest(".comment_box");
      let subcomments = parent.nextElementSibling;
      if (!subcomments || !subcomments.classList.contains("subcomments")) {
        const div = document.createElement("div");
        div.className = "subcomments";
        parent.after(div);
        subcomments = div;
      }
      subcomments.append(newComment);
      formEl.remove();
    }
    window.location.hash = newComment.id;
  });

  $(".main").on("ajax:error", "form.comment", function (_e, xhr) {
    const p = document.createElement("p");
    p.className = "errors";
    p.textContent = xhr.status === 422 ? xhr.responseText : "Извините, произошла ошибка.";
    this.before(p);
  });
}

export default {
  init() {
    document.addEventListener('DOMContentLoaded', function () {
      const formEl = document.querySelector("form[data-comment-form]");
      if (!formEl) return;
      form = formEl.cloneNode(true);
      initReplyLinks();
      initCommentForms();
    });
  }
};
