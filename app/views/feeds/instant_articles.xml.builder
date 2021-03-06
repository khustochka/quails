# frozen_string_literal: true

xml.rss version: "2.0", "xmlns:content" => "http://purl.org/rss/1.0/modules/content" do
  xml.channel do
    xml.title "Birdwatch.org.ua"
    xml.link blog_url
    xml.description "Дневник наблюдений за птицами"
    xml.language "ru"

    @posts.each do |post|
      xml.item do
        xml.title post.decorated.title
        xml.link public_post_url(post, only_path: false)
        xml.content :encoded do
          xml.cdata! render(partial: "feeds/article", locals: { post: post }, formats: :html, layout: false)
        end
        xml.guid public_post_url(post, only_path: false)
        xml.pubDate post.face_date.iso8601
        xml.author t("author.name")
      end
    end
  end
end
