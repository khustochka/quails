class FeedFormatStrategy < SiteFormatStrategy

  private

  def only_path?
    @only_path = false
  end

  def default_url_options
    {host: @metadata[:host], port: extract_port, protocol: "https"}
  end

  def extract_port
    port = @metadata[:port].presence
    port = nil if port.in?([80, 443])
    port
  end

  def preprocess(text)
    url_prefix = "https://#{@metadata[:host]}#{extract_port}/"
    super(text).
        gsub(/(href|src)=("|')\//, "\\1=\\2#{url_prefix}").
        gsub(/:\/(?!\/)/, ":#{url_prefix}")
  end

end
