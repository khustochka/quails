require 'test_helper'

class PostTest < ActiveSupport::TestCase

  should 'not be saved with empty code' do
    blogpost      = Factory.build(:post)
    blogpost.code = ''
    assert_raise(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  should 'not be saved with existing code' do
    Factory.create(:post, :code => 'kiev-observations')
    blogpost      = Factory.build(:post)
    blogpost.code = 'kiev-observations'
    assert_raise(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  should 'not be saved with empty title' do
    blogpost       = Factory.build(:post)
    blogpost.title = ''
    assert_raise(ActiveRecord::RecordInvalid) do
      blogpost.save!
    end
  end

  should 'calculate previous month correctly (one having posts) even for month with no posts' do
    blogpost1 = Factory.create(:post, :created_at => '2010-02-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :created_at => '2009-11-06 13:14:15', :code => 'post-two')
    blogpost3 = Factory.create(:post, :created_at => '2009-10-06 13:14:15', :code => 'post-tri')
    assert_nil Post.prev_month('2009', '10')
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2009', '12'))
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2010', '01'))
    assert_equal({:month => '11', :year => '2009'}, Post.prev_month('2010', '02'))
  end

  should 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = Factory.create(:post, :created_at => '2010-02-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :created_at => '2009-11-06 13:14:15', :code => 'post-two')
    blogpost1 = Factory.create(:post, :created_at => '2010-03-06 13:14:15', :code => 'post-tri')
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2009', '11'))
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2009', '12'))
    assert_equal({:month => '02', :year => '2010'}, Post.next_month('2010', '01'))
    assert_nil Post.next_month('2010', '03')
  end

end
