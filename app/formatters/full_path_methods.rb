# frozen_string_literal: true

module FullPathMethods
  def default_url_options
    {only_path: false, host: @metadata[:host], port: extract_port, protocol: "https"}
  end

  def extract_port
    port = @metadata[:port].presence
    port = nil if port.in?([80, 443])
    port
  end
end
