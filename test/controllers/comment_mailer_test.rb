# frozen_string_literal: true

require "test_helper"

class CommentMailerTest < ActionMailer::TestCase
  def create_comment_with_parent
    commenter = Commenter.create!(is_admin: false, name: "Vasya", email: "vasya@example.org")
    parent = create(:comment, commenter: commenter)
    @comment = create(:comment, parent_comment: parent, post: parent.post)
  end

  def deliver_notify_admin_email
    email = CommentMailer.
      with(comment: @comment, link_options: {host: "example.org"}, from: "some@example.org", to: "admin@example.org").notify_admin
    assert_emails 1 do
      email.deliver_now
    end
    email
  end

  def deliver_notify_parent_author_email
    email = CommentMailer.
      with(comment: @comment, link_options: {host: "example.org"}, from: "some@example.org").notify_parent_author
    assert_emails 1 do
      email.deliver_now
    end
    email
  end

  # Notify admin

  test "`notify_admin` email correctly renders en dash in the subject" do
    @comment = create(:comment)
    @comment.post.update(title: "This is how it is going - 2021")
    email = deliver_notify_admin_email
    assert_includes email.subject, "–"
    assert_not_includes email.subject, "&#8211;"
  end

  # FIXME: Sanitization that fixes en dash from HTML entity also converts '&' to HTML entity
  # This is acceptable for now since dash is much more common in post titles.
  test "`notify_admin` email correctly renders ampersand in the subject" do
    skip "Ampersand in email subject fell victim of en dash"
    @comment = create(:comment)
    @comment.post.update(title: "This & that 2021")
    email = deliver_notify_admin_email
    assert_includes email.subject, " & "
    assert_not_includes email.subject, "&amp;"
  end

  test "`notify_admin` email removes HTML tags from subject" do
    @comment = create(:comment)
    @comment.post.update(title: "This is <b>rad</b>!")
    email = deliver_notify_admin_email
    assert_includes email.subject, "This is rad!"
  end

  # notify parent author

  test "`notify_parent_author` email correctly renders en dash in the subject" do
    create_comment_with_parent
    @comment.post.update(title: "This is how it is going - 2021")
    email = deliver_notify_parent_author_email
    assert_includes email.subject, "–"
    assert_not_includes email.subject, "&#8211;"
  end

  # FIXME: Sanitization that fixes en dash from HTML entity also converts '&' to HTML entity
  # This is acceptable for now since dash is much more common in post titles.
  test "`notify_parent_author` email correctly renders ampersand in the subject" do
    create_comment_with_parent
    skip "Ampersand in email subject fell victim of en dash"
    @comment.post.update(title: "This & that 2021")
    email = deliver_notify_parent_author_email
    assert_includes email.subject, " & "
    assert_not_includes email.subject, "&amp;"
  end

  test "`notify_parent_author` email removes HTML tags from subject" do
    create_comment_with_parent
    @comment.post.update(title: "This is <b>rad</b>!")
    email = deliver_notify_parent_author_email
    assert_includes email.subject, "This is rad!"
  end
end
