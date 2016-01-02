module Aspects
  module Security
    def self.included(klass)
      klass.extend ClassMethods
      klass.helper_method :current_user, :url_options_for_admin

      #force HTTP
      if Quails.env.ssl?
        klass.before_action :force_http
      end

    end

    module ClassMethods

      def requires_admin_authorized(*args)
        options = args.extract_options!
        before_action options do
          unless current_user.admin?
            if current_user.has_trust_cookie?
              flash[:ret] = request.url
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

    def url_options_for_admin
      @@url_options_for_admin ||=
          {locale: nil}.merge!(
              Quails.env.ssl? ? {only_path: false, protocol: 'https'} : {}
          )
    end

    def force_http
      if request.ssl? && !current_user.has_trust_cookie?
        redirect_to({only_path: false, protocol: 'http', status: 301})
      end
    end

    def force_ssl_for_admin
      if !request.ssl? && current_user.has_trust_cookie?
        redirect_to({only_path: false, protocol: 'https', status: 301})
      end
    end

  end
end
