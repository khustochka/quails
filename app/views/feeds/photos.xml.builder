atom_feed(:id => "tag:#{request.host},2008-03-24:/gallery") do |feed|
  feed.title("Birds photos")
  feed.updated(@photos.first.created_at) if @photos.any?
  feed.author do |a|
    a.name('Vitalii Khustochka')
  end

  @photos.each do |img|
    img_title = image_title(img)

    # TODO: Use haml or ERB instead
    content = <<CONTENT
<p>#{link_to image_tag(jpg_url(img), :alt => img_title), public_image_path(img), :title => img_title}</p>
<p><i>#{img.species.map(&:name_sci) * ', '}</i></p>

<p>#{[l(img.observ_date, :format => :long), img.locus.name_en] * ', '}</p>

#{wiki_filter(img.description)}

#{(p = img.post) ? "<p>Post: #{post_link(post_title(p), p, true)}</p>" : ''}
CONTENT

    feed.entry(img,
               :url => public_image_path(img),
               :id => "tag:#{request.host},2008-03-24:#{public_image_path(img)}") do |entry|
      entry.title(img_title, :type => 'html')
      entry.content(content, :type => 'html')
    end
  end
end