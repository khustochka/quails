ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'rspec/expectations'

class ActiveSupport::TestCase

  delegate :public_post_path, :public_image_path, :to => :@controller

  TEST_CREDENTIALS = Hashie::Mash.new YAML::load_file('config/security_devtest.yml')['test']

  def login_as_admin
    CredentialsVerifier.set_cookie(@controller)
    @request.env['HTTP_AUTHORIZATION'] =
        ActionController::HttpAuthentication::Basic.encode_credentials(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password_plain)
  end

end
