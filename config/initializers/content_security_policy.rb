# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

report_uri = if (key = ENV["HONEYBADGER_API_KEY"])
  "https://api.honeybadger.io/v1/browser/csp?api_key=#{key}&env=#{Rails.env}"
else
  "/csp-violation-report-endpoint"
end

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline # Inline styles on justified views
    # Specify URI for violation reports
    policy.report_uri report_uri
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # Do not include style-src below, otherwise `unsafe_inline` will be ignored.
  config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = false
end
