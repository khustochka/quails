module VideoEmbedder

  def video_embed(term)
    if video = Video.find_by(slug: term)
      youtube_embed = video.large
      VideoEmbedder.erb_template.result(binding)
    end
  end

  private
  def self.erb_template
    @template ||= ERB.new File.new(Rails.root.join('app/views/videos/_youtube_embed.html.erb')).read, nil, "%"
  end

end
