class FeedFormatStrategy < SiteFormatStrategy

  def initialize(text, metadata = {})
    port = metadata[:port].presence
    port = port && port != 80 && port != 443
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
    port = @metadata[:port].presence
    port = port && port != 80 && port != 443
    {host: @metadata[:host], port: port, protocol: "https"}
  end

end
