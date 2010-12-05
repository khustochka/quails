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

end
