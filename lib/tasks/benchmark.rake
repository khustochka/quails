# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  video = Video.last

  Benchmark.ips do |bench|
    bench.report("ActionView") do
      embed = video.representation.full_size
      ActionView::Base.with_empty_template_cache.with_view_paths(["app/views"], {}).render "videos/youtube_embed", embed: embed, privacy: true
    end

    bench.report("ActiveController::Rendered") do
      embed = video.representation.full_size
      ApplicationController.renderer.new.render partial: "videos/youtube_embed", locals: { embed: embed, privacy: true }
    end

    bench.compare!
  end
end

task bench: :benchmark
