atom_feed(:id => "tag:#{request.host},2008-03-24:/blog") do |feed|
  feed.title("Birdwatching diary")
  feed.updated(@posts.first.face_date)
  feed.author do |a|
    a.name('Vitalii Khustochka')
  end

  @posts.each do |post|
    feed.entry(post,
               :published => post.face_date,
               :url => public_post_path(post),
               :id => "tag:#{request.host},#{post.face_date.strftime("%F")}:/blog/#{post.code}") do |entry|
      entry.title(post.title)
      entry.content(wiki_filter(post), :type => 'html')
    end
  end
end