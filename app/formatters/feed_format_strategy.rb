class FeedFormatStrategy < SiteFormatStrategy

  include FullPathMethods

  private

  def only_path?
    @only_path = false
  end

  def preprocess(text)
    url_prefix = "https://#{@metadata[:host]}#{extract_port}/"
    super(text).
        gsub(/(href|src)=("|')\//, "\\1=\\2#{url_prefix}").
        gsub(/:\/(?!\/)/, ":#{url_prefix}")
  end

end
