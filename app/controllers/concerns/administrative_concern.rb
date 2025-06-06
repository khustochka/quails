# frozen_string_literal: true

module AdministrativeConcern
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :admin_layout?, :administrative?
  end

  def administrative?
    @administrative
  end

  def admin_layout?
    @admin_layout
  end

  private :admin_layout?

  module ClassMethods
    def administrative(options = {})
      requires_admin_authorized options
      before_action options do
        @administrative = true
        @admin_layout = true
        @scripts ||= []
        # "administrativeX" should be first because it loads keypress.js
        @scripts.unshift "administrativeX"
        @scripts.push "administrative"
        params.permit!
      end
    end
  end
end
