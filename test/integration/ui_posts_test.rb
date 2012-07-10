require 'test_helper'
require 'capybara_helper'

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding post" do
    login_as_admin
    visit new_post_path
    fill_in('Slug', with: 'new-post')
    fill_in('Title', with: 'Test post')
    fill_in('Text', with: 'Post text.')
    select('OPEN', from: 'Status')
    select('OBSR', from: 'Topic')
    click_button('Save')
    blogpost = Post.find_by_slug('new-post')
    expect(current_path).to eq(show_post_path(blogpost.to_url_params))
  end

  test "Editing post" do
    blogpost = create(:post)
    login_as_admin
    visit edit_post_path(blogpost)
    fill_in('Slug', with: 'changed-post')
    fill_in('Title', with: 'Test post edited')
    fill_in('Text', with: 'Post text edited.')
    fill_in('Post date', with: '2009-07-27')
    click_button('Save')
    blogpost = Post.find_by_slug('changed-post')
    expect(current_path).to eq(show_post_path(blogpost.to_url_params))
  end

  test "Navigation via Edit this and Show this links" do
    blogpost = create(:post)
    login_as_admin
    visit show_post_path(blogpost.to_url_params)
    click_link('Edit this one')
    expect(current_path).to eq(edit_post_path(blogpost))
    click_link('Show this one')
    expect(current_path).to eq(show_post_path(blogpost.to_url_params))
  end

  test "Add comment to post" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    expect(page).to have_content("Vasya")

  end

  test "Add reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#new_comment") do
      fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    expect(current_path).to eq(show_post_path(blogpost.to_url_params))
    expect(page).to have_content("Vasya")
    expect(comment.subcomments.size).to eq(1)
  end

  test "Try to post invalid comment (no JS)" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    expect(current_path).to eq(comments_path)
    # TODO: remove strip when https://github.com/jnicklas/capybara/issues/677 is fixed
    expect(find('#comment_text').text.lstrip).to eq('Some text')
  end

  test "Try to post invalid reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    expect(current_path).to eq(comments_path)
    # TODO: remove strip when https://github.com/jnicklas/capybara/issues/677 is fixed
    expect(find('#comment_text').text.lstrip).to eq('Some text')
  end

end
