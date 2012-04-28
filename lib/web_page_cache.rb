class WebPageCache < ActiveSupport::Cache::FileStore

  # Simply caching web pages in FileStore
  def fetch(name, url, options = nil)
    verbose = options.delete(:verbose)
    puts "... Probing the cache" if verbose
    super(name, options) do
      puts "... Getting #{url}" if verbose
      open(url).read
    end
  end

end
