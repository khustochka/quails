require 'test_helper'
require 'capybara_helper'

class JSCardsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  def save_and_check
    click_button('Save')
    assert page.has_css?("#save_button[value=Save]")
  end

  def select_date(value)
    page.execute_script "$('.inline_date').datepicker( 'setDate', '#{value}' );"
  end
  private :save_and_check, :select_date

  test "Adding empty card" do
    login_as_admin
    visit new_card_path

    find(:xpath, "//span[text()='Add new row']").click

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-08')
    assert_difference('Card.count') do
      save_and_check
    end
    card = Card.first
    assert_equal edit_card_path(card), current_path
  end

  test "Create card with observations" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-08')

    find(:xpath, "//span[text()='Add new row']").click

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Passer domesticus', from: 'Taxon')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Hirundo rustica', from: 'Taxon')
    end

    assert_difference('Observation.count', 2) { save_and_check }
  end

  test "Create card, add new row with observation and save" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-08')

    find(:xpath, "//span[text()='Add new row']").click

    assert_equal 1, all('.obs-row').size

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Passer domesticus', from: 'Taxon')
    end

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Hirundo rustica', from: 'Taxon')
    end

    assert_difference('Observation.count', 2) { save_and_check }
  end

  test "Quick add species" do
    login_as_admin
    visit new_card_path

    select_suggestion('Passer domesticus', from: 'species-quick-add')

    assert_equal 1, all('.obs-row').size

    field = find(:xpath, "//div[contains(@class,'obs-row')][1]//input[contains(@class, 'sp-light')]")

    assert_equal 'Passer domesticus - House Sparrow', field.value

    assert_equal taxa(:pasdom).id.to_s, field.find(:xpath, "./following-sibling::input", visible: false).value
  end

  test "Remove row" do
    login_as_admin
    visit new_card_path

    find(:xpath, "//span[text()='Add new row']").click

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      click_icon_link(".remove")
    end

    assert_equal 1, all('.obs-row').size
  end

  test "Destroy observation from card page" do

    @card = create(:card)
    o = create(:observation, taxon: taxa(:pasdom), card: @card)

    login_as_admin

    visit edit_card_path(@card)

    assert page.has_css?('.obs-row div a', text: o.id.to_s)

    assert_difference('Observation.count', -1) do
      within(:xpath, "//div[contains(@class,'obs-row')][1]") do
        accept_confirm do
          click_icon_link(".destroy")
        end
      end

      assert_equal edit_card_path(@card), current_path
      assert page.has_no_css?('.obs-row div a', text: o.id.to_s)
    end
    assert_equal 0, all('.obs-row').size
  end

  test "Save card after observation removal" do

    @card = create(:card)
    o = create(:observation, taxon: taxa(:hirrus), card: @card)
    o2 = create(:observation, taxon: taxa(:pasdom), card: @card)

    login_as_admin
    visit edit_card_path(@card)

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      accept_confirm do
        click_icon_link(".destroy")
      end
    end

    assert page.has_no_css?('.obs-row div a', text: o.id.to_s)
    assert page.has_no_css?("input[value='#{o.id.to_s}'][type=hidden]")

    save_and_check

    assert_equal edit_card_path(@card), current_path
  end

  test 'Species autosuggest box should have spuhs and be able to add them' do
    login_as_admin
    visit new_card_path
    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-08')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Aves sp.', from: 'Taxon')
    end

    assert_difference('Observation.count', 1) { save_and_check }
    assert_equal taxa(:aves_sp), Observation.order(id: :desc).first.taxon
  end

  test "Clicking on voice checkbox label should not change the wrong checkbox" do
    login_as_admin
    visit new_card_path

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    find(:xpath, "//span[text()='Add new row']").click

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][3]") do
      find('label', text: 'Voice?').click
    end

    assert find(:xpath, "//div[contains(@class,'obs-row')][3]").has_checked_field?('Voice?')
    assert_not find(:xpath, "//div[contains(@class,'obs-row')][1]").has_checked_field?('Voice?')
    assert_not find(:xpath, "//div[contains(@class,'obs-row')][2]").has_checked_field?('Voice?')
  end

  test "Adding observations for the post" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add new card'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Passer domesticus', from: 'Taxon')
      assert_equal taxa(:pasdom).id.to_s, find(:css, "input.hidden", visible: false).value.to_s, "Taxon not selected properly"
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Hirundo rustica', from: 'Taxon')
      assert_equal taxa(:hirrus).id.to_s, find(:css, "input.hidden", visible: false).value.to_s, "Taxon not selected properly"
    end
    assert_difference('Observation.count', 2) { save_and_check }

    assert_equal 2, blogpost.cards[0].observations.size
  end

  test "Start adding observations for post but then uncheck it" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add new card'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-09')
    uncheck('card_post_id')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Passer domesticus', from: 'Taxon')
    end

    assert_difference('Observation.count', 1) { save_and_check }

    assert_empty blogpost.cards
  end

  test "Add observations for post, then save unlinked" do
    blogpost = create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add new card'

    assert page.has_css?('label a', text: blogpost.title)

    select_suggestion('Brovary', from: 'Location')
    select_date('2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Passer domesticus', from: 'Taxon')
    end

    save_and_check

    assert_not_empty blogpost.cards
    card = blogpost.cards[0]

    uncheck('card_post_id')
    save_and_check

    assert_empty blogpost.reload.cards
    assert_nil card.reload.post_id
  end

  test 'Attach card to the post' do
    create(:card, observ_date: "2010-06-18")

    p = create(:post)

    login_as_admin
    visit edit_post_path(p)
    fill_in('Date:', with: "2010-06-18")

    click_button('Search')

    assert page.has_css?('li.observ_card')

    accept_confirm do
      page.find('li.observ_card').click_link('Attach to this post')
    end

    assert page.has_no_css?('.loading')

    assert_equal 1, p.cards.size
  end

end
