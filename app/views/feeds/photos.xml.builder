atom_feed(:id => "tag:#{request.host},2008-03-24:/gallery") do |feed|
  feed.title("Birds photos")
  feed.updated(@photos.first.created_at) if @photos.present?
  feed.author do |a|
    a.name t('author.name')
  end

  @photos.each do |img|
    feed.entry(img,
               :url => image_path(img),
               :id => "tag:#{request.host},2008-03-24:#{image_path(img)}") do |entry|
      entry.title(img.formatted.title, :type => 'html')
      entry.content(render(partial: 'image', formats: :html, object: img), :type => 'html')
    end
  end
end
