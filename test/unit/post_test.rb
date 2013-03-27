require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "post factory is valid" do
    create(:post)
    create(:post)
  end

  test 'do not save post with empty slug' do
    blogpost = build(:post, slug: '')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test 'do not save post with existing slug' do
    create(:post, slug: 'kiev-observations')
    blogpost = build(:post, slug: 'kiev-observations')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test 'do not save post with empty title' do
    blogpost = build(:post, title: '')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
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
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2009-10-06 13:14:15')
    assert_nil Post.prev_month('2009', '10')
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2009', '12'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '01'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '02'))
  end

  test 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15')
    blogpost1 = create(:post, face_date: '2010-03-06 13:14:15')
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '11'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '12'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2010', '01'))
    assert_nil Post.next_month('2010', '03')
  end

  test 'do not delete associated observations on post destroy' do
    blogpost = create(:post, face_date: '2010-02-06 13:14:15')
    observation = create(:observation, post: blogpost)
    blogpost.destroy
    assert observation.reload
    assert_nil observation.post_id
    assert_nil observation.post
  end

  test 'face date is treated as timezone-less' do
    blogpost = create(:post, face_date: '2013-01-01 00:30:00') # risky time (different days in GMT and EEST)
    assert_include(Post.year(2013).pluck(:id), blogpost.id)
    assert_not_include(Post.year(2012).pluck(:id), blogpost.id)
  end

  test 'calculate next and previous months correctly (last day in mind)' do
    create(:post, face_date: '2011-01-20 12:30:00')
    create(:post, face_date: '2011-01-31 23:53:00') # last day and risky time
    create(:post, face_date: '2011-02-01 00:30:00') # risky time (different days in GMT and EEST)
    create(:post, face_date: '2011-02-15 12:53:00')
    assert_equal({month: '02', year: '2011'}, Post.next_month('2011', '01'))
    assert_equal({month: '01', year: '2011'}, Post.prev_month('2011', '02'))
  end

  test 'adding image to post should touch posts`s updated_at' do
    p = create(:post)
    saved_date = p.updated_at

    sleep 1

    o = create(:observation, post_id: p.id)
    p.reload
    assert_equal saved_date.to_i, p.updated_at.to_i

    sleep 1

    i = create(:image, observation_ids: [o.id])
    p.reload
    assert p.updated_at.to_i > saved_date.to_i
  end

  test 'moving image to another observation should touch posts`s updated_at' do
    p = create(:post)
    saved_date = p.updated_at

    o = create(:observation, post_id: p.id)
    i = create(:image, observation_ids: [o.id])

    sleep 1

    o2 = create(:observation)
    i.observation_ids = [o2.id]

    p.reload
    assert p.updated_at.to_i > saved_date.to_i

  end

end
