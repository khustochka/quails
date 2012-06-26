require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "post factory is valid" do
    create(:post)
    create(:post)
  end

  test 'do not save post with empty slug' do
    blogpost = build(:post, slug: '')
    expect { blogpost.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'do not save post with existing slug' do
    create(:post, slug: 'kiev-observations')
    blogpost = build(:post, slug: 'kiev-observations')
    expect { blogpost.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  test 'do not save post with empty title' do
    blogpost = build(:post, title: '')
    expect { blogpost.save! }.to raise_error(ActiveRecord::RecordInvalid)
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
    Post.prev_month('2009', '12').should eq({month: '11', year: '2009'})
    Post.prev_month('2010', '01').should eq({month: '11', year: '2009'})
    Post.prev_month('2010', '02').should eq({month: '11', year: '2009'})
  end

  test 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15')
    blogpost1 = create(:post, face_date: '2010-03-06 13:14:15')
    Post.next_month('2009', '11').should eq({month: '02', year: '2010'})
    Post.next_month('2009', '12').should eq({month: '02', year: '2010'})
    Post.next_month('2010', '01').should eq({month: '02', year: '2010'})
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
    Post.year(2013).pluck(:id).should include(blogpost.id)
    Post.year(2012).pluck(:id).should_not include(blogpost.id)
  end

  test 'calculate next and previous months correctly (last day in mind)' do
    create(:post, face_date: '2011-01-20 12:30:00')
    create(:post, face_date: '2011-01-31 23:53:00') # last day and risky time
    create(:post, face_date: '2011-02-01 00:30:00') # risky time (different days in GMT and EEST)
    create(:post, face_date: '2011-02-15 12:53:00')
    Post.next_month('2011', '01').should eq({month: '02', year: '2011'})
    Post.prev_month('2011', '02').should eq({month: '01', year: '2011'})
  end

end
