require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = FactoryGirl.create(:comment)
  end

  test 'destroying comments when post is destroyed' do
    assert_difference('Comment.count', -1) do
      @comment.post.destroy
    end
    Comment.where(:id => @comment.id).all.should be_empty
  end
end
