# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with session" do
    connect(session: { admin: true })

    assert_equal "admin", connection.current_user
  end
end
