require 'test_helper'

class SpotTest < ActiveSupport::TestCase
  test "spot factory is valid" do
    create(:spot)
  end
end
