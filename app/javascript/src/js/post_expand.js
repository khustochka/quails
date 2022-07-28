class PostExpander {
  constructor(el) {
    let link = $("<span class='pseudolink lang_expand_link'>" + $(el).data("expand-link") + "</span>");
    $("p", el).append(link);
    this.link = $(link);
    this.toExpand = $(el).siblings(".other_lang_expand");
    this.toExpand.hide();
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
  $(".diff_lang_expand_notice[data-expand-link]").each(function (i, el) {
    const postExpander = new PostExpander(el);
    postExpander.register();
  });
})
