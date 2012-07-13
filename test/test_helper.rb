begin
  require 'simplecov'
  SimpleCov.start 'rails'
rescue LoadError, RuntimeError
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'rspec/expectations'

Locus::PUBLIC_LOCI.push('new_york') # needed for tests

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods

  delegate :root_url, :public_post_path, :public_image_path, :public_comment_path, :url_for, to: :@controller

  TEST_CREDENTIALS = OpenStruct.new(YAML::load_file('config/security.yml')['test']['admin'])

  def login_as_admin
    @request.env['HTTP_AUTHORIZATION'] =
        ActionController::HttpAuthentication::Basic.encode_credentials(TEST_CREDENTIALS.username, TEST_CREDENTIALS.password)
  end

  @@seed = HashWithIndifferentAccess.new do |hash, term|
    hash[term] = Locus.find_by_slug(term) || Species.find_by_code!(term)
  end

  def seed(key)
    @@seed[key]
  end

  # current path that preserves arguments after ? and # (unlike current_path)
  def current_path_info
    current_url.sub(%r{.*?://}, '')[%r{[/\?\#].*}] || '/'
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
