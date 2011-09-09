class TmpCache

  # Simple caching to tmp/
  # Searches for `file` in tmp/
  # If there is no file - downloads `url` to it
  # `force = true` forces download
  def self.fetch(file, url, force = false)
    if force || !File.exists?("tmp/#{file}")
      IO.copy_stream(open(url), "tmp/#{file}")
    end
    File.open("tmp/#{file}")
  end
end