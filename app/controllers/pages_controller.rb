class PagesController < ApplicationController

  caches_page :show, :error, gzip: true

  def show
    render params[:id]
  end

  def error
    public_path = Rails.public_path
    status = params[:code]
    path = "#{public_path}/#{status}.html"

    unless File.exists?(path)
      body = render_to_string status, layout: 'error'
      # `caches_page` is an after-filter, it is not called on erroneous status, so caching manually
      cache_page(body, '/404', Zlib::BEST_COMPRESSION)
    end

    render text: File.read(path), status: status.to_i
    Rails.logger.info("Read #{status}.html from filesystem")
  end
end
