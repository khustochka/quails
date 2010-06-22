module AssetsController
  def self.included(klass)
    klass.extend ClassMethods
    klass.before_filter do
      @stylesheets = []
      @scripts = []
    end
  end

  module ClassMethods
    def stylesheet(*args)
      options = args.extract_options!
      before_filter options do
        @stylesheets += args
      end
    end

    def javascript(*args)
      options = args.extract_options!
      before_filter options do
        @scripts += args
      end
    end
  end
end