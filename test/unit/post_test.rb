require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test 'not be saved with empty code' do
    blogpost      = Factory.build(:post)
    blogpost.code = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test 'not be saved with existing code' do
    Factory.create(:post, :code => 'kiev-observations')
    blogpost      = Factory.build(:post)
    blogpost.code = 'kiev-observations'
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test 'not be saved with empty title' do
    blogpost       = Factory.build(:post)
    blogpost.title = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  test 'set face_date to current (equal to updated_at) when creating' do
    blogpost       = Factory.create(:post)
    assert_equal blogpost.updated_at, blogpost.face_date
  end

  test 'set face_date to current (equal to updated_at) when saving with empty value' do
    blogpost       = Factory.create(:post, :updated_at => '2008-01-01 02:02:02')
    blogpost.face_date = ''
    blogpost.save!
    blogpost.reload
    assert_equal blogpost.updated_at, blogpost.face_date
  end

  test 'calculate previous month correctly (one having posts) even for month with no posts' do
    blogpost1 = Factory.create(:post, :face_date => '2010-02-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2009-11-06 13:14:15', :code => 'post-two')
    blogpost3 = Factory.create(:post, :face_date => '2009-10-06 13:14:15', :code => 'post-tri')
    assert_nil Post.prev_month('2009', '10')
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2009', '12'))
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2010', '01'))
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2010', '02'))
  end

  test 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = Factory.create(:post, :face_date => '2010-02-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :face_date => '2009-11-06 13:14:15', :code => 'post-two')
    blogpost1 = Factory.create(:post, :face_date => '2010-03-06 13:14:15', :code => 'post-tri')
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2009', '11'))
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2009', '12'))
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2010', '01'))
    assert_nil Post.next_month('2010', '03')
  end

  test 'not delete associated observations on destroy' do
    blogpost = Factory.create(:post, :face_date => '2010-02-06 13:14:15', :code => 'post-one')
    observation = Factory.create(:observation, :post => blogpost)
    blogpost.destroy
    assert observation.reload
    assert_nil observation.post_id
    assert_nil observation.post
  end

end
