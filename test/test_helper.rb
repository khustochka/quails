require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'rspec/expectations'

class ActiveSupport::TestCase

  delegate :public_post_path, :public_image_path, :url_for, :to => :@controller

  TEST_CREDENTIALS = Hashie::Mash.new(YAML::load_file('config/security_devtest.yml')['test']['admin'])

  def login_as_admin
    @request.env['HTTP_AUTHORIZATION'] =
        ActionController::HttpAuthentication::Basic.encode_credentials(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password)
  end

  @@seed = HashWithIndifferentAccess.new do |hash, code|
    hash[code] = Locus.find_by_code(code) || Species.find_by_code!(code)
  end

  def seed(key)
    @@seed[key]
  end

  def self.test(name, &block)
    test_name = "test: #{name}. ".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

end