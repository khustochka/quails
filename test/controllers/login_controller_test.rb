# frozen_string_literal: true

require "test_helper"

class LoginControllerTest < ActionController::TestCase
  test "login page remembers where the user came from" do
    @request.env["HTTP_REFERER"] = "http://test.host/about"
    get :new

    assert_response :success
    assert_equal "pages", session[:ret][:controller]
    assert_equal "about", session[:ret][:id]
  end

  test "login page ignores a referrer from another host" do
    @request.env["HTTP_REFERER"] = "http://evil.example.com/about"
    get :new

    assert_response :success
    assert_nil session[:ret]
  end

  test "login page ignores an unrecognized referrer path" do
    @request.env["HTTP_REFERER"] = "http://test.host/no/such/path/at/all"
    get :new

    assert_response :success
    assert_nil session[:ret]
  end

  test "login page ignores a malformed referrer" do
    @request.env["HTTP_REFERER"] = "http://test.host/\\"
    get :new

    assert_response :success
    assert_nil session[:ret]
  end

  test "login page keeps an already stored return path when there is no referrer" do
    session[:ret] = { "controller" => "blog", "action" => "home" }
    get :new

    assert_response :success
    assert_equal "blog", session[:ret]["controller"]
  end

  test "wrong credentials are rejected" do
    post :login, params: { username: "nobody", password: "wrong" }

    assert_response :forbidden
    assert_nil session[:admin]
  end

  test "the return path survives a failed login attempt" do
    session[:ret] = { "controller" => "blog", "action" => "home" }
    post :login, params: { username: "nobody", password: "wrong" }

    assert_response :forbidden
    assert_equal "blog", session[:ret]["controller"]
  end

  test "logout clears the session and returns to the referrer" do
    login_as_admin
    @request.env["HTTP_REFERER"] = "http://test.host/about"

    get :logout

    assert_redirected_to "http://test.host/about"
    assert_nil session[:admin]
  end

  test "logout without a referrer returns to the root" do
    login_as_admin

    get :logout

    assert_redirected_to "http://test.host/"
    assert_nil session[:admin]
  end
end
