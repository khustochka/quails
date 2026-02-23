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
  document.querySelector(".main").addEventListener("ajax:before", function (e) {
    if (!e.target.matches("form.comment")) return;
    e.target.querySelectorAll("p.errors").forEach(p => p.remove());
  });

  document.querySelector(".main").addEventListener("ajax:success", function (e) {
    if (!e.target.matches("form.comment")) return;
    const formEl = e.target;
    const doc = e.detail[0];
    const newComment = doc.body.firstElementChild;
    if ("commentForm" in formEl.dataset) {
      document.getElementById("add_comment").before(newComment);
      formEl.replaceWith(form.cloneNode(true));
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

  document.querySelector(".main").addEventListener("ajax:error", function (e) {
    if (!e.target.matches("form.comment")) return;
    const formEl = e.target;
    const xhr = e.detail[0];
    const p = document.createElement("p");
    p.className = "errors";
    p.textContent = xhr.status === 422 ? xhr.responseText : "Извините, произошла ошибка.";
    formEl.before(p);
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
