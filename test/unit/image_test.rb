require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  setup do
  end

  test "image factory is valid" do
    create(:image)
  end

  test "prev and next image by species should be correct for different days" do
    o1 = create(:observation, observ_date: "2013-01-01")
    o2 = create(:observation, observ_date: "2013-02-01")
    o3 = create(:observation, observ_date: "2013-03-01")
    s = o1.species
    im1 = create(:image, observations: [o1])
    im2 = create(:image, observations: [o2])
    im3 = create(:image, observations: [o3])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

  test "prev and next image by species should be correct for the same day" do
    o = create(:observation)
    s = o.species
    im1 = create(:image, observations: [o])
    im2 = create(:image, observations: [o])
    im3 = create(:image, observations: [o])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

  test "prev and next image by species should be correct if even created_at is the same" do
    o = create(:observation)
    s = o.species
    tm = Time.now
    im1 = create(:image, observations: [o], created_at: tm)
    im2 = create(:image, observations: [o], created_at: tm)
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im2, im1.next_by_species(s)
  end

  test "prev and next image by species should be correct for reversed created_at" do
    o1 = create(:observation, observ_date: "2013-01-01")
    o2 = create(:observation, observ_date: "2013-02-01")
    o3 = create(:observation, observ_date: "2013-03-01")
    s = o1.species
    im3 = create(:image, observations: [o3])
    im2 = create(:image, observations: [o2])
    im1 = create(:image, observations: [o1])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

end
