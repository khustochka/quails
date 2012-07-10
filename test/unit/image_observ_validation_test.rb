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
    expect(img.errors).not_to be_blank
  end

  test "does not update image with empty observation list" do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    expect(@image.update_with_observations(new_attr, [])).to be_false
    expect(@image.errors).not_to be_blank
  end

  test "does not update image if no observation list provided" do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    expect(@image.update_with_observations(new_attr, nil)).to be_false
    expect(@image.errors).not_to be_blank
  end

 test "restores observation list if image was not saved due to its emptiness" do
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['slug'] = 'new_img_slug'
    @image.update_with_observations(new_attr, [])
    expect(@image.observation_ids).to eq(@image.observation_ids)
  end

test "does not restore former observation list if image was not saved not due to their emptiness" do
    new_attr = @image.attributes.dup # observations_ids are not in here
    new_attr['slug'] = ''
    new_obs = create(:observation)
    @image.update_with_observations(new_attr, [new_obs.id])
    expect(@image.observation_ids).to eq([new_obs.id])
  end

 test 'excludes duplicated observations on image create' do
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    img = Image.new
    assert_difference('Image.count', 1) do
      img.update_with_observations(new_attr, [@obs.id, @obs.id])
    end
    expect(img.errors).to be_empty
    expect(img.observation_ids).to eq([@obs.id])
  end

test 'excludes duplicated observation (existing) on image update' do
    new_attr = @image.attributes.dup
    obs = create(:observation)
    expect(@image.update_with_observations(new_attr, [@obs.id, @obs.id, obs.id])).to be_true
    expect(@image.errors).to be_empty
    expect(@image.observation_ids.count).to eq(2)
  end

test 'excludes duplicated observation (new) on image update' do
    new_attr = @image.attributes.dup
    obs = create(:observation)
    expect(@image.update_with_observations(new_attr, [@obs.id, obs.id, obs.id])).to be_true
    expect(@image.errors).to be_empty
    expect(@image.observation_ids.count).to eq(2)
  end

 test 'does not create image with inconsistent observations (different date)' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    expect(img.errors).not_to be_blank
  end

test 'does not create image with inconsistent observations (different loc)' do
    obs1 = create(:observation, locus: seed(:kiev))
    obs2 = create(:observation, locus: seed(:krym))
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    expect(img.errors).not_to be_blank
  end

  test 'does not create image with inconsistent observations (mine-not mine)' do
    obs1 = create(:observation, mine: true)
    obs2 = create(:observation, mine: false)
    new_attr = build(:image).attributes
    img = Image.new
    assert_difference('Image.count', 0) do
      img.update_with_observations(new_attr, [obs1.id, obs2.id])
    end
    expect(img.errors).not_to be_blank
  end

test 'does not update image with inconsistent observations' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = @image.attributes
    expect(@image.update_with_observations(new_attr, [obs1.id, obs2.id])).to be_false
    expect(@image.errors).not_to be_blank
  end

test 'preserves changed values if image failed to update with inconsistent observations' do
    obs1 = create(:observation, observ_date: '2011-01-01')
    obs2 = create(:observation, observ_date: '2010-01-01')
    new_attr = build(:image).attributes
    expect(@image.update_with_observations(new_attr, [obs1.id, obs2.id])).to be_false
    expect(@image.errors).not_to be_blank
  end

end
