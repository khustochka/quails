# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with session" do
    connect(session: {admin: true})

    assert_equal connection.current_user, "admin"
  end
end
