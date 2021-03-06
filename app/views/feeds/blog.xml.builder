# frozen_string_literal: true

atom_feed(id: "tag:#{request.host},2008-03-24:/blog", language: :ru) do |feed|
  feed.title("Дневник наблюдений за птицами - birdwatch.org.ua")
  feed.updated(@posts.max_by(&:updated_at).updated_at) if @posts.present?
  feed.author do |a|
    a.name t("author.name")
  end

  @posts.each do |post|
    feed.entry(post,
               published: post.face_date,
               url: public_post_url(post, only_path: false),
               id: "tag:#{request.host},#{post.face_date.strftime('%F')}:#{public_post_path(post)}") do |entry|
      entry.title(post.decorated.title, type: "html")
      entry.content(render(partial: "post", formats: :html, object: post), type: "html")
    end
  end
end
