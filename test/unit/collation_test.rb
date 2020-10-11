# frozen_string_literal: true

require 'test_helper'

class CollationTest < ActiveSupport::TestCase

  test 'collation should be C' do
    assert_match /^C/, ActiveRecord::Base.connection.select_rows("SHOW LC_COLLATE")[0][0]
  end

end
