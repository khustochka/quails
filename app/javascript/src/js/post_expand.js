class PostExpander {
  constructor(link) {
    this.link = $(link);
    this.toExpand = $(link).closest(".diff_lang_expand_notice").siblings(".other_lang_expand");
  }

register() {
    const _this = this;
    this.link.on("click", function () {
      _this.toExpand.show();
      _this.link.hide();
    });
  }
}


document.addEventListener('DOMContentLoaded', function () {
  $(".lang_expand_link").each(function (i, el) {
    const postExpander = new PostExpander(el);
    postExpander.register();
  });
})
