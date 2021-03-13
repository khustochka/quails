# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = create(:comment)
  end

  test "destroying comments when post is destroyed" do
    assert_difference("Comment.count", -1) do
      @comment.post.destroy
    end
    assert_empty Comment.where(id: @comment.id)
  end

  test "destroying comments when parent comment is destroyed" do
    blogpost = @comment.post
    create(:comment, post: blogpost, parent_id: @comment.id)
    assert_difference("Comment.count", -2) do
      @comment.destroy
    end
    assert_empty Comment.where(post_id: blogpost.id)
  end

  test "conflicting post id and parent id" do
    comment1 = FactoryBot.create(:comment)
    post1 = comment1.post
    comment2 = FactoryBot.create(:comment)
    post2 = comment2.post
    subcomment = Comment.create(
        name: "Vasya", body: "Hello", approved: true,
        post_id: post1.id, parent_id: comment2.id
    )
    assert_not_predicate subcomment, :valid?
  end
end
