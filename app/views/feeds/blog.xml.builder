# frozen_string_literal: true

atom_feed(id: "tag:#{request.host},2008-03-24:/blog", language: I18n.locale, schema_date: "2008") do |feed|
  feed.title(t(".title"))
  feed.updated(@posts.max_by(&:updated_at).updated_at) if @posts.present?
  feed.author do |a|
    a.name t(".author")
  end

  @posts.each do |post|
    feed.entry(post,
      published: post.face_date,
      url: default_public_post_url(post),
      id: "tag:#{request.host},#{post.face_date.strftime("%F")}:#{public_post_path(post)}") do |entry|
      entry.title(post.decorated.title, type: "html", "xml:lang": post.lang)
      entry.content(render(partial: "post", formats: :html, object: post), type: "html", "xml:lang": post.lang)
    end
  end
end
