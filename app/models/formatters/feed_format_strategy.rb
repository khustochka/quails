class FeedFormatStrategy < SiteFormatStrategy

  def initialize(text, metadata = {})
    port = extract_port(metadata)
    port = port ? ":#{port}" : ""
    new_text = text.
        gsub(/(href|src)=("|')\//, "\\1=\\2https://#{metadata[:host]}#{port}/").
        gsub(/:\/(?!\/)/, ":https://#{metadata[:host]}#{port}/")
    super(new_text, metadata)
  end

  private

  def only_path?
    @only_path = false
  end

  def default_url_options
    {host: @metadata[:host], port: extract_port(@metadata), protocol: "https"}
  end

  def extract_port(metadata)
    port = metadata[:port].presence
    port = nil if port.in?([80, 443])
  end

end
