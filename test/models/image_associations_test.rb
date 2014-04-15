require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  setup do
    @obs = create(:observation)
    @image = create(:image, observations: [@obs])
  end

  test 'properly link images with one species' do
    sp = @obs.species

    assert_equal [@image.slug], sp.images.pluck(:slug)
    assert_equal [sp.code], @image.species.pluck(:code)
  end

  test 'properly link images with several species' do
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, species: sp1, card: card)
    obs2 = create(:observation, species: sp2, card: card)
    img = create(:image, slug: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])

    assert_equal [img.slug], sp1.images.pluck(:slug)
    assert_equal [img.slug], sp2.images.pluck(:slug)
    assert_empty ([sp1.code, sp2.code] - img.species.pluck(:code))
  end

  test 'properly link image and post' do
    blogpost = create(:post, observations: [@obs])

    assert_equal [@image], blogpost.images
    @image.reload
    assert_equal [blogpost], @image.posts(Post.public_posts)
  end

  test 'properly unlink observations when image destroyed' do
    @image.destroy
    assert @obs.reload
    assert_equal 0, @obs.images.size
  end

end
