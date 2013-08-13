class FeedFormatStrategy < SiteFormatStrategy

  def initialize(text, metadata = {})
    new_text = text.
        gsub(/(href|src)=("|')\//, "\\1=\\2http://#{metadata[:host]}/").
        gsub(/:\//, ":http://#{metadata[:host]}/")
    super(new_text, metadata)
  end

  private

  def only_path?
    false
  end

  def default_url_options
    {host: @metadata[:host]}
  end

end
