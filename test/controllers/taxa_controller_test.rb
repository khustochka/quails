require "test_helper"

class TaxaControllerTest < ActionController::TestCase
  def setup
    @book = Book.find_by_slug('fesenko-bokotej')
  end

  test 'show taxon' do
    login_as_admin
    get :show, book_id: @book, id: 'Gavia_stellata'
    assert_response :success
    assert_not_nil assigns(:taxon)
  end

  test 'update taxon' do
    login_as_admin
    new_values = {name_en: "Zzz zzz"}
    get :update, book_id: @book, id: 'Gavia_stellata', taxon: new_values
    assert_redirected_to book_taxon_path(@book, assigns(:taxon))
    assert_equal "Zzz zzz", assigns(:taxon).name_en
  end

  test 'not allowed to use Latin name already taken in this book' do
    login_as_admin
    new_values = {name_sci: "Gavia immer"}

    get :update, book_id: @book, id: 'Gavia_stellata', taxon: new_values
    assert assigns(:taxon).errors.present?
  end

  #test 'allowed to use Latin name taken in another book' do
  #  login_as_admin
  #  new_values = {name_sci: "Cardinalis cardinalis"}
  #  get :update, book_id: @book, id: 'Gavia_stellata', taxon: new_values
  # assert_redirected_to book_taxon_path(@book, assigns(:taxon))
  #  assert_equal "Cardinalis cardinalis", assigns(:taxon).name_sci
  #end
end
