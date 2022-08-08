# frozen_string_literal: true

require "test_helper"

class CorrectableTest < ActionController::TestCase
  tests PostsController

  setup do
    @correction = create(:correction)
    @post1 = create(:post, body: "Link http://google.com", face_date: "2022-08-02")
    @post2 = create(:post, body: "Link https://google.com", face_date: "2022-08-01")
    @post3 = create(:post, body: "Link http://flickr.com", face_date: "2022-07-29")
    login_as_admin
  end

  test "when submitted with Skip it redirects to the next record" do
    login_as_admin
    put :update, params: { id: @post3.to_param, correction: @correction.id, commit: CorrectableConcern::SKIP_VALUE, post: { title: "New title" } }
    @post3.reload
    assert_not_equal "New title", @post3.title
    assert_redirected_to [:edit, @post1, { correction: @correction.id }]
  end

  test "when submitted with Save it saves and returns to the same edit form" do
    put :update, params: { id: @post3.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_VALUE, post: { title: "New title" } }
    @post3.reload
    assert_equal "New title", @post3.title
    assert_redirected_to [:edit, @post3, { correction: @correction.id }]
  end

  test "when submitted with Save and next it saves and redirects to the next record" do
    put :update, params: { id: @post3.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_AND_NEXT_VALUE, post: { title: "New title" } }
    @post3.reload
    assert_equal "New title", @post3.title
    assert_redirected_to [:edit, @post1, { correction: @correction.id }]
  end

  test "when submitted with errors (Save and next) it returns to the same edit form" do
    put :update, params: { id: @post3.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_VALUE, post: { title: "" } }
    @post3.reload
    assert_not_equal "New title", @post3.title
    assert_template :form
  end

  test "when the last record is reached it redirects to the correction page with a flash message" do
    put :update, params: { id: @post1.to_param, correction: @correction.id, commit: CorrectableConcern::SAVE_AND_NEXT_VALUE, post: { title: "New title" } }
    @post1.reload
    assert_equal "New title", @post1.title
    assert_redirected_to [:edit, @correction]
    assert_equal "You have reached the last record!", flash[:notice]
  end
end
