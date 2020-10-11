# frozen_string_literal: true

require 'test_helper'

class SpotTest < ActiveSupport::TestCase
  test "spot factory is valid" do
    create(:spot)
  end

  test "destroy spot when observation is destroyed" do
    spot = create(:spot)
    spot_id = spot.id
    obs = spot.observation
    obs.destroy
    assert Spot.where(id: spot_id).empty?, "Spot was not removed"
  end

  test "unlink image when spot is destroyed" do
    spot = create(:spot)
    img = create(:image, spot: spot)
    spot.destroy
    img.reload
    assert_nil img.spot_id
  end
end
