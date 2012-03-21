require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test 'do not save post with empty code' do
    blogpost = build(:post, code: '')
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test 'do not save post with existing code' do
    create(:post, code: 'kiev-observations')
    blogpost = build(:post, code: 'kiev-observations')
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test 'do not save post with empty title' do
    blogpost = build(:post, title: '')
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test "set post's face_date to current (equal to updated_at) when creating" do
    blogpost = create(:post)
    assert_equal blogpost.updated_at.strftime('%F %T'), blogpost.face_date.strftime('%F %T')
  end

  test "set post's face_date to current (equal to updated_at) when saving with empty value" do
    blogpost = create(:post, updated_at: '2008-01-01 02:02:02')
    blogpost.update_attributes(face_date: '')
    blogpost.reload
    assert_equal blogpost.updated_at.strftime('%F %T'), blogpost.face_date.strftime('%F %T')
  end

  test 'calculate previous month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15', code: 'post-one')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15', code: 'post-two')
    blogpost3 = create(:post, face_date: '2009-10-06 13:14:15', code: 'post-tri')
    assert_nil Post.prev_month('2009', '10')
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2009', '12'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '01'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '02'))
  end

  test 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15', code: 'post-one')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15', code: 'post-two')
    blogpost1 = create(:post, face_date: '2010-03-06 13:14:15', code: 'post-tri')
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '11'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '12'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2010', '01'))
    assert_nil Post.next_month('2010', '03')
  end

  test 'do not delete associated observations on post destroy' do
    blogpost = create(:post, face_date: '2010-02-06 13:14:15', code: 'post-one')
    observation = create(:observation, post: blogpost)
    blogpost.destroy
    assert observation.reload
    assert_nil observation.post_id
    assert_nil observation.post
  end

  test 'face date is treated as timezone-less' do
    blogpost = create(:post, face_date: '2013-01-01 00:30:00')
    Post.year(2013).pluck(:id).should include(blogpost.id)
    Post.year(2012).pluck(:id).should_not include(blogpost.id)
  end

end
