class FeedFormatStrategy < SiteFormatStrategy

  def initialize(text, metadata = {})
    new_text = text.
        gsub(/(href|src)=("|')\//, "\\1=\\2http://#{metadata[:host]}/").
        gsub(/:\/(?!\/)/, ":http://#{metadata[:host]}/")
    super(new_text, metadata)
  end

  private

  def only_path?
    if @only_path.nil?
      @only_path = false
    end
    @only_path
  end

  # FIXME: this omits the port!
  def default_url_options
    {host: @metadata[:host]}
  end

end
