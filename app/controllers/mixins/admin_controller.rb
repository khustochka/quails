module AdminController

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods

    def administrative(options={})
      requires_admin_authorized options
      use_layout 'admin', options
    end

  end
end
