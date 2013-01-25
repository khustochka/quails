module AdminController

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods

    def administrative(options={})
      requires_admin_authorized options
      before_filter options do
        @admin_layout = true
      end
    end

  end
end
