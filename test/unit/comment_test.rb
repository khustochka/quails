require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = create(:comment)
  end

  test 'destroying comments when post is destroyed' do
    assert_difference('Comment.count', -1) do
      @comment.post.destroy
    end
    expect(Comment.where(id: @comment.id).all).to be_empty
  end

  test 'destroying comments when parent comment is destroyed' do
    blogpost = @comment.post
    create(:comment, post: blogpost, parent_id: @comment.id)
    assert_difference('Comment.count', -2) do
      @comment.destroy
    end
    expect(Comment.where(post_id: blogpost.id).all).to be_empty
  end
end
