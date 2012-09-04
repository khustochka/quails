require 'test_helper'

class ImageObservValidationTest < ActiveSupport::TestCase

  setup do
    @obs = create(:observation)
    @image = create(:image, observations: [@obs])
  end

  test "does not create image with no observations" do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [])
    end
    assert_present img.errors
  end

  test "does not update image with empty observation list" do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    assert_false @image.update_with_observations(new_attr, [])
    assert_present @image.errors
  end

  test "does not update image if no observation list provided" do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    assert_false @image.update_with_observations(new_attr, nil)
    assert_present @image.errors
  end

 test "restores observation list if image was not saved due to its emptiness" do
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['slug'] = 'new_img_slug'
    @image.update_with_observations(new_attr, [])
    assert_equal @image.observation_ids, @image.observation_ids
  end

test "does not restore former observation list if image was not saved not due to their emptiness" do
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['slug'] = ''
    new_obs = create(:observation)
    @image.update_with_observations(new_attr, [new_obs.id])
    assert_equal [new_obs.id], @image.observation_ids
  end

 test 'excludes duplicated observations on image create' do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    img = Image.new
    assert_difference('Image.count', 1) do
      img.update_with_observations(new_attr, [@obs.id, @obs.id])
    end
    assert_empty img.errors
    assert_equal [@obs.id], img.observation_ids
  end

test 'excludes duplicated observation (existing) on image update' do
    new_attr = @image.attributes.dup
    obs = create(:observation)
    assert @image.update_with_observations(new_attr, [@obs.id, @obs.id, obs.id])
    assert_empty @image.errors
    assert_equal 2, @image.observation_ids.count
  end

test 'excludes duplicated observation (new) on image update' do
    new_attr = @image.attributes.dup
    obs = create(:observation)
    assert @image.update_with_observations(new_attr, [@obs.id, obs.id, obs.id])
    assert_empty @image.errors
    assert_equal 2, @image.observation_ids.count
  end

 test 'does not create image with inconsistent observations (different date)' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    assert_present img.errors
  end

test 'does not create image with inconsistent observations (different loc)' do
    obs1 = create(:observation, locus: seed(:kiev))
    obs2 = create(:observation, locus: seed(:krym))
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    assert_present img.errors
  end

  test 'does not create image with inconsistent observations (mine-not mine)' do
    obs1 = create(:observation, mine: true)
    obs2 = create(:observation, mine: false)
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    assert_present img.errors
  end

test 'does not update image with inconsistent observations' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = @image.attributes
    assert_false @image.update_with_observations(new_attr, [obs1.id, obs2.id])
    assert_present @image.errors
  end

test 'preserves changed values if image failed to update with inconsistent observations' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = build(:image).attributes
    assert_false @image.update_with_observations(new_attr, [obs1.id, obs2.id])
    assert_present @image.errors
  end

end
