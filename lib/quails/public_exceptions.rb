# frozen_string_literal: true

module Quails
  class PublicExceptions
    attr_accessor :public_path

    def initialize(public_path)
      @public_path = public_path
    end

    def call(env)
      @env = env
      request      = ActionDispatch::Request.new(env)
      status       = request.path_info[1..-1].to_i
      begin
        content_type = request.formats.first
      rescue ActionDispatch::Http::MimeNegotiation::InvalidType
        content_type = Mime[:text]
      end
      body = { status: status, error: Rack::Utils::HTTP_STATUS_CODES.fetch(status, Rack::Utils::HTTP_STATUS_CODES[500]) }

      render(status, content_type, body)
    end

    private

    def render(status, content_type, body)
      format = "to_#{content_type.to_sym}" if content_type
      if format && body.respond_to?(format)
        render_format(status, content_type, body.public_send(format))
      else
        render_html(status)
      end
    end

    def render_format(status, content_type, body)
      [status, { "Content-Type" => "#{content_type}; charset=#{ActionDispatch::Response.default_charset}",
                 "Content-Length" => body.bytesize.to_s, }, [body],]
    end

    def render_html(status)
      # FIXME: On production cached {404,500}.html will not be in public folder,
      # but 422, 503 are. The best solution is to implement static 404, 500 pages.
      path = "#{public_path}/#{status}.#{I18n.locale}.html"
      path = "#{public_path}/#{status}.html" unless (found = File.exist?(path))

      if found || File.exist?(path)
        render_format(status, "text/html", File.read(path))
      else
        ErrorsController.action(:show).call(@env)
      end
    end
  end
end
