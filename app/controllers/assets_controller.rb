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
      before_filter do
        @stylesheets += args
      end
    end

    def javascript(*args)
      before_filter do
        @scripts += args
      end
    end
  end
end