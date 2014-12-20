if ENV['COVERAGE'] == 'true'
  begin
    require 'simplecov'
    SimpleCov.start 'rails'
  rescue LoadError, RuntimeError
  end
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods

  delegate :public_post_path, :public_comment_path, :url_for, to: :@controller

  def login_as_admin
    @request.session[User.cookie_name] = User.cookie_value
  end

  @@seed = HashWithIndifferentAccess.new do |hash, term|
    hash[term] = Locus.find_by(slug: term) || Species.find_by!(code: term)
  end

  def seed(key)
    @@seed[key]
  end

  # current path that preserves arguments after ? and # (unlike current_path)
  def current_path_info
    current_url.sub(%r{.*?://}, '')[%r{[/\?\#].*}] || '/'
  end

end
