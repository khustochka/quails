module Aspects
  module Administrative

    def self.included(klass)
      klass.extend ClassMethods
      klass.helper_method :admin_layout?
    end

    def admin_layout?
      @admin_layout
    end

    private :admin_layout?

    module ClassMethods

      def administrative(options={})
        requires_admin_authorized options
        before_action options do
          @admin_layout = true
          @scripts ||= []
          @scripts.push 'administrative'
          params.permit!
        end
      end

    end
  end
end
