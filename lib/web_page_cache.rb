# frozen_string_literal: true

# rubocop:disable Rails/Output, Lint/MissingCopEnableDirective
class WebPageCache < ActiveSupport::Cache::FileStore
  # Simply caching web pages in FileStore
  def fetch(name, url, options = {})
    # Essentially unused.
    verbose = options.delete(:verbose)
    puts "... Probing the cache" if verbose
    super(name, options) do
      puts "... Getting #{url}" if verbose
      open(url).read # rubocop:disable Security/Open
    end
  end
end
