# frozen_string_literal: true

module FormatStrategy
  class Feed < Site
    include FullPathMethods

    private
    # Fixing the user-inserted host-less links
    def preprocess(text)
      url_prefix = "https://#{@metadata[:host]}#{extract_port}/"
      super(text).
        gsub(/(href|src)=("|')\//, "\\1=\\2#{url_prefix}").
        gsub(/:\/(?!\/)/, ":#{url_prefix}")
    end
  end
end
