# frozen_string_literal: true

xml.rss version: "2.0", "xmlns:content" => "http://purl.org/rss/1.0/modules/content" do
  xml.channel do
    xml.title "Birdwatch.org.ua"
    xml.link blog_url
    xml.description t("feeds.instant_articles.title")
    xml.language I18n.locale.to_s

    @posts.each do |post|
      xml.item do
        xml.title post.decorated.title
        xml.link default_public_post_url(post)
        xml.content :encoded do
          xml.cdata! render(partial: "feeds/article", locals: { post: post }, formats: :html, layout: false)
        end
        xml.guid default_public_post_url(post)
        xml.pubDate post.face_date.iso8601
        xml.author t("author.name")
      end
    end
  end
end
