# frozen_string_literal: true

module SecurityConcern
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :current_user
    klass.helper_method :has_trust_cookie?
  end

  module ClassMethods
    def requires_admin_authorized(*args)
      options = args.extract_options!
      before_action options do
        unless current_user.admin?
          if has_trust_cookie?
            session[:ret] = params
            redirect_to login_path
          else
            raise ActionController::RoutingError, "Restricted path"
          end
        end
      end
    end
  end

  TRUST_COOKIE_NAME = -"quails_visit"
  TRUST_COOKIE_VALUE = -"I believe you"
  private_constant :TRUST_COOKIE_NAME
  private_constant :TRUST_COOKIE_VALUE

  private

  def current_user
    @current_user ||= user_from_session
  end

  def has_trust_cookie?
    cookies.signed[TRUST_COOKIE_NAME] == TRUST_COOKIE_VALUE
  end

  def user_from_session
    current_span = defined?(Datadog) ? Datadog::Tracing.active_span : nil
    if session[:admin] == true
      current_span&.set_tag("admin", true)
      Admin.new
    else
      User.new
    end
  end
end
