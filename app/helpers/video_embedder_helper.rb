# frozen_string_literal: true

module VideoEmbedderHelper
  def video_embed(term, size = :large)
    if video = Video.find_by(slug: term)
      youtube_embed = video.send(size)
      VideoEmbedderHelper.erb_template.result(binding)
    end
  end

  private
  def self.erb_template
    @template ||= ERB.new File.new(Rails.root.join("app/views/videos/_youtube_embed.html.erb")).read, nil, "%"
  end
end
