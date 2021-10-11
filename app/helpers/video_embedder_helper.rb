# frozen_string_literal: true

module VideoEmbedderHelper
  def video_embed(term, size = :full_size)
    if video = Video.find_by(slug: term)
      embed = video.representation.send(size)
      privacy = true
      renderer = ApplicationController.renderer.new
      renderer.render partial: "videos/youtube_embed", locals: { embed: embed, privacy: privacy }
      #   See also config/initializers/application_controller_renderer.rb

      # This approach seems simpler but is 3x slower, see benchmark.
      # ActionView::Base.with_empty_template_cache.with_view_paths(["app/views"], {}).render "videos/youtube_embed", embed: embed, privacy: privacy



    end
  end
end
