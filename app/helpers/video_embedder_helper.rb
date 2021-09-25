# frozen_string_literal: true

module VideoEmbedderHelper
  def video_embed(term, size = :full_size)
    if video = Video.find_by(slug: term)
      embed = video.representation(privacy: false).send(size)
      VideoEmbedderHelper.erb_template.result(binding)
    end
  end

  private
  def self.erb_template
    @template ||= ERB.new File.new(Rails.root.join("app/views/videos/_youtube_embed.html.erb")).read, trim_mode: "%"
  end
end
