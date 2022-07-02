# frozen_string_literal: true

require "test_helper"

class BlobsControllerTest < ActionController::TestCase
  test "show blob" do
    login_as_admin
    blob = ActiveStorage::Blob.create_and_upload!(io: fixture_file_upload("tules.jpg"), filename: "tules.jpg")
    get :show, params: { id: blob.signed_id }
    assert_response :success
  end

  test "create blob" do
    login_as_admin
    post :create, params: { stored_image: fixture_file_upload("tules.jpg") }
    assert_redirected_to blob_path(ActiveStorage::Blob.last.signed_id)
  end
end
