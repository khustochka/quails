module Aspects
  module Security
    def self.included(klass)
      klass.extend ClassMethods
      klass.helper_method :current_user
    end

    module ClassMethods

      def requires_admin_authorized(*args)
        options = args.extract_options!
        before_action options do
          unless current_user.admin?
            if current_user.has_trust_cookie?
              session[:ret] = params
              redirect_to login_path
            else
              raise ActionController::RoutingError, "Restricted path"
            end
          end
        end
      end


    end

    private
    def current_user
      @current_user ||= User.from_session(request)
    end
  end
end
