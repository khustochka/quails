# frozen_string_literal: true

require 'test_helper'

class BooksControllerTest < ActionController::TestCase

  setup do
    Book.create!(slug: "fesenko-bokotej")
  end

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
      post :create, params: {book: {slug: 'ebird_000', name: 'eBird 0.00'}}
    end
    assert_redirected_to book_path(assigns(:book))
  end

  test "show book" do
    login_as_admin
    get :show, params: {id: 'fesenko-bokotej'}
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, params: {id: 'fesenko-bokotej'}
    assert_response :success
  end

  test "update book" do
    book = Book.find_by(slug: 'fesenko-bokotej')
    book.name = 'changed'
    login_as_admin
    put :update, params: {id: book.to_param, book: book.attributes}
    assert_redirected_to book_path(assigns(:book))
    book.reload
    assert_equal 'changed', book.name
  end

  test "destroy book" do
    assert_difference('Book.count', -1) do
      login_as_admin
      delete :destroy, params: {id: 'fesenko-bokotej'}
    end

    assert_redirected_to books_path
  end

end
