atom_feed(id: "tag:#{request.host},2008-03-24:/gallery", root_url: url_for({action: 'index', controller: 'images', only_path: false}), language: I18n.locale) do |feed|
  feed.title(t('.title'))
  feed.updated(@photos.first.created_at) if @photos.present?
  feed.author do |a|
    a.name t('author.name')
  end

  @photos.each do |img|
    feed.entry(img,
               :url => image_url(img, only_path: false),
               :id => "tag:#{request.host},2008-03-24:#{image_url(img)}") do |entry|
      entry.title(img.formatted.title, :type => 'html')
      entry.content(render(partial: 'image', formats: :html, object: img), :type => 'html')
    end
  end
end
