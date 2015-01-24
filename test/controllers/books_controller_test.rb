require 'test_helper'

class BooksControllerTest < ActionController::TestCase

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:books)
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create book" do
    assert_difference('Book.count') do
      login_as_admin
      post :create, book: {slug: 'ebird_000', name: 'eBird 0.00'}
    end
    assert_redirected_to book_path(assigns(:book))
  end

  test "show book" do
    login_as_admin
    get :show, id: 'fesenko-bokotej'
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, id: 'fesenko-bokotej'
    assert_response :success
  end

  test "update book" do
    book = Book.find_by(slug: 'fesenko-bokotej')
    book.name = 'changed'
    login_as_admin
    put :update, id: book.to_param, book: book.attributes
    assert_redirected_to book_path(assigns(:book))
    book.reload
    assert_equal 'changed', book.name
  end

  test "destroy book should not be possible if it has taxa" do
    login_as_admin
    assert_raise(ActiveRecord::DeleteRestrictionError) { delete :destroy, id: 'fesenko-bokotej' }
  end

end
