atom_feed(:id => "tag:#{request.host},2008-03-24:/blog") do |feed|
  feed.title("Birdwatching diary")
  feed.updated(@posts.first.face_date) if @posts.present?
  feed.author do |a|
    a.name t('author.name')
  end

  @posts.each do |post|
    feed.entry(post,
               :published => post.face_date,
               :url => public_post_path(post),
               :id => "tag:#{request.host},2008-03-24:#{public_post_path(post)}") do |entry|
      entry.title(post.formatted.title, :type => 'html')
      entry.content(render(partial: 'post', formats: :html, object: post), :type => 'html')
    end
  end
end
