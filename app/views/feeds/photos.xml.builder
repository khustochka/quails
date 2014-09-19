atom_feed(id: "tag:#{request.host},2008-03-24:/gallery", root_url: url_for({action: 'index', controller: 'images', only_path: false}), language: I18n.locale) do |feed|
  feed.title(t('.title'))
  feed.updated(@media.first.created_at) if @media.present?
  feed.author do |a|
    a.name t('author.name')
  end

  @media.each do |media|
    feed.entry(media,
               :url => localize_url(media, only_path: false),
               :id => "tag:#{request.host},2008-03-24:#{localize_url(media)}") do |entry|
      entry.title(media.formatted.title, :type => 'html')
      entry.content(
          render(partial: 'media', formats: :html, object: media), :type => 'html'
      )
    end
  end
end
