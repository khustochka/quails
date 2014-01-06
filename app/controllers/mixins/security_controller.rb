module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :current_user

    #force HTTP
    if Quails.env.ssl?
      klass.before_filter do
        if request.ssl? && !current_user.has_trust_cookie?
          redirect_to({only_path: false, protocol: 'http'})
        end
      end
    end

  end

  module ClassMethods

    def requires_admin_authorized(*args)
      options = args.extract_options!
      before_filter options do
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
    @current_user ||= User.detect(request)
  end

end
