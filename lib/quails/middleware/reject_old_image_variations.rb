# frozen_string_literal: true

module Quails
  module Middleware
    class RejectOldImageVariations
      def initialize(app)
        @app = app
      end

      # There is a number of requests coming in from supposedly serach engines, using the old
      # imagemagick format of image variation (probably saved in their cache). This causes the app
      # to download the image from S3 and then fail trying to transform it. I intercept these
      # requests and, if the format is "old style", return status 410 Gone, saving time and resources.
      def call(env)
        path = env["REQUEST_PATH"]
        # Example: "/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NDU2LCJwdXIiOiJibG9iX2lkIn19--0725a4b28311825e3491eeaf468e2c097835cbb2/eyJfcmFpbHMiOnsiZGF0YSI6eyJmb3JtYXQiOiJqcGciLCJyZXNpemUiOiI5MDB4XHUwMDNlIn0sInB1ciI6InZhcmlhdGlvbiJ9fQ==--587830dc97a4febfbe9828f32b5f12a279dbabbd/woodpecker23311.jpg"

        path_match = path&.match(%r[/rails/active_storage/representations/redirect/[^/]*/([^/-]*)--[0-9a-f]*/[^/]*])

        if path_match
          begin
            variation = JSON.parse(Base64.decode64(path_match[1]))

            if variation.dig("_rails", "data", "resize").is_a?(String)
              # Cache response for 1 hour (in case we are blocking good requests). Increase after test.
              return [410, { "cache-control" => "max-age=3600" }, ["Gone"]]
            elsif (message = variation.dig("_rails", "message"))
              decoded_message = Base64.decode64(message)
              # Old style resize looks like "1200x>", so checking for that
              if decoded_message.include?("resize") && decoded_message.include?("x>")
                return [410, { "cache-control" => "max-age=3600" }, ["Gone"]]
              end
            end
          rescue
            # decoding error? just ignore, in case it is something legitimate
          end
        end

        @status, @headers, @response = @app.call(env)

        [@status, @headers, @response]
      end
    end
  end
end
