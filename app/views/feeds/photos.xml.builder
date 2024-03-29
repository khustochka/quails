# frozen_string_literal: true

atom_feed(id: "tag:#{request.host},2008-03-24:/gallery",
  root_url: localized_images_url(only_path: false),
  language: I18n.locale,
  schema_date: "2008") do |feed|
  feed.title(t(".title"), "xml:lang": I18n.locale.to_s)
  feed.updated(@media.first.created_at) if @media.present?
  feed.author do |a|
    a.name t("author.name")
  end

  @media.each do |original_media|
    media = original_media.extend_with_class
    feed.entry(media,
      url: localize_url(media),
      id: "tag:#{request.host},#{media.created_at.strftime("%F")}:#{localize_path(media)}") do |entry|
      entry.title(media.decorated.title, type: "html")
      entry.content(
        render(partial: "media", formats: :html, object: media), type: "html", "xml:lang": I18n.locale.to_s
      )
    end
  end
end
