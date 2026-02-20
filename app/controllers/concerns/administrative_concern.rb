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
        params.permit!
      end
    end
  end
end
