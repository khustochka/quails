require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "post factory is valid" do
    create(:post)
    create(:post)
  end

  test 'do not save post with empty slug' do
    blogpost = build(:post, slug: '')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test 'do not save post with existing slug' do
    create(:post, slug: 'kiev-observations')
    blogpost = build(:post, slug: 'kiev-observations')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test 'slug cannot contain space' do
    blogpost = build(:post, slug: 'kiev observations')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test 'do not save post with empty title' do
    blogpost = build(:post, title: '')
    assert_raise(ActiveRecord::RecordInvalid) { blogpost.save! }
  end

  test "set post's face_date to current (equal to updated_at) when creating" do
    blogpost = create(:post)
    assert_equal blogpost.updated_at.strftime('%F %T'), blogpost.face_date.strftime('%F %T')
  end

  test "set post's face_date to current (equal to updated_at) when saving with empty value" do
    blogpost = create(:post, updated_at: '2008-01-01 02:02:02', face_date: "2008-01-01")
    blogpost.update_attributes(face_date: "")
    blogpost.reload
    assert_equal blogpost.updated_at.strftime('%F %T'), blogpost.face_date.strftime('%F %T')
  end

  test 'calculate previous month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15')
    blogpost3 = create(:post, face_date: '2009-10-06 13:14:15')
    assert_nil Post.prev_month('2009', '10')
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2009', '12'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '01'))
    assert_equal({month: '11', year: '2009'}, Post.prev_month('2010', '02'))
  end

  test 'calculate next month correctly (one having posts) even for month with no posts' do
    blogpost1 = create(:post, face_date: '2010-02-06 13:14:15')
    blogpost2 = create(:post, face_date: '2009-11-06 13:14:15')
    blogpost1 = create(:post, face_date: '2010-03-06 13:14:15')
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '11'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2009', '12'))
    assert_equal({month: '02', year: '2010'}, Post.next_month('2010', '01'))
    assert_nil Post.next_month('2010', '03')
  end

  test 'do not delete associated observations on post destroy' do
    blogpost = create(:post, face_date: '2010-02-06 13:14:15')
    observation = create(:observation, post: blogpost)
    blogpost.destroy
    assert observation.reload
    assert_nil observation.post_id
    assert_nil observation.post
  end

  test 'face date is treated as timezone-less' do
    blogpost = create(:post, face_date: '2013-01-01 00:30:00') # risky time (different days in GMT and EEST)
    assert_includes(Post.year(2013).pluck(:id), blogpost.id)
    assert_not_includes(Post.year(2012).pluck(:id), blogpost.id)
  end

  test 'calculate next and previous months correctly (last day in mind)' do
    create(:post, face_date: '2011-01-20 12:30:00')
    create(:post, face_date: '2011-01-31 23:53:00') # last day and risky time
    create(:post, face_date: '2011-02-01 00:30:00') # risky time (different days in GMT and EEST)
    create(:post, face_date: '2011-02-15 12:53:00')
    assert_equal({month: '02', year: '2011'}, Post.next_month('2011', '01'))
    assert_equal({month: '01', year: '2011'}, Post.prev_month('2011', '02'))
  end

  test 'adding image to post should touch posts`s updated_at' do
    p = create(:post)
    saved_date = p.updated_at

    travel 1.minute

    o = create(:observation, post: p)

    travel 2.minutes

    i = create(:image, observation_ids: [o.id])
    p.reload
    assert p.updated_at.to_i > saved_date.to_i

    travel_back
  end

  # FIXME: the NEW post is touched if it exists, but not the OLD!
  # FIXME: crazy unstable test!!!
  # test 'moving image to another observation of another card should touch posts`s updated_at' do
  #   p = create(:post)
  #   saved_date = p.updated_at
  #
  #   o = create(:observation, post: p)
  #   i = create(:image, observations: [o])
  #
  #   o2 = create(:observation)
  #
  #   sleep 2
  #
  #   i.update({observation_ids: [o2.id]})
  #
  #   p.reload
  #   assert p.updated_at.to_i > saved_date.to_i
  #
  # end

  # !
  test 'moving image to another observation of the same card should touch posts`s updated_at' do
    p = create(:post)
    saved_date = p.updated_at
    card = create(:card, post: p)

    o = create(:observation, card: card)
    i = create(:image, observations: [o])

    o2 = create(:observation, card: card)

    travel 1.minute

    # Have to refind it to clear association cache
    img = Image.find(i.id)

    img.update({observation_ids: [o2.id]})

    p.reload
    assert p.updated_at.to_i > saved_date.to_i

    travel_back
  end

  test 'destroying image should touch posts`s updated_at' do
    p = create(:post)
    saved_date = p.updated_at
    card = create(:card, post: p)

    o = create(:observation, card: card)
    i = create(:image, observations: [o])

    travel 1.minute

    # Have to refind it to clear association cache
    img = Image.find(i.id)

    img.destroy

    p.reload
    assert p.updated_at.to_i > saved_date.to_i

    travel_back
  end

  # !
  test 'moving card out of the post should touch post' do
    p = create(:post)
    saved_date = p.updated_at
    card = create(:card, post: p)

    travel 1.minute


    # Have to refind it to clear association cache
    c = Card.find card.id
    c.post = nil
    c.save!

    p.reload
    assert p.updated_at.to_i > saved_date.to_i

    travel_back

  end

  test 'proper post species list for observations attached to post' do
    p = create(:post)
    c = create(:card, post: p)
    o = create(:observation, card: c, taxon: taxa(:hirrus))
    o2 = create(:observation, post_id: p.id, taxon: taxa(:pasdom))

    assert_equal 2, p.species.to_a.size
  end

  test 'proper post images list for observations attached to post' do
    p = create(:post)
    c = create(:card, post: p)
    o = create(:observation, card: c, taxon: taxa(:hirrus))
    o2 = create(:observation, post_id: p.id, taxon: taxa(:pasdom))
    create(:image, observations: [o])
    create(:image, observations: [o2])

    assert_equal 2, p.images.to_a.size
  end

  test 'post images should not be duplicated (if multi-species)' do
    p = create(:post)
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card = create(:card, observ_date: "2008-07-01", post: p)
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    img = create(:image, slug: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])

    assert_equal 1, p.images.to_a.size
  end

  test "new species count should not be duplicated if new species was seen twice in a day" do
    p = create(:post)
    card1 = create(:card, observ_date: "2015-04-27", post: p)
    obs1 = create(:observation, taxon: taxa(:hirrus), card: card1)
    card2 = create(:card, observ_date: "2015-04-27", post: p)
    obs2 = create(:observation, taxon: taxa(:hirrus), card: card2)
    assert_equal 1, p.new_species_ids.size
  end

  test 'do not show on homepage the images that are already in post body' do
    p = create(:post, text: "First paragraph\n\n{{^image1}}\n\nLast paragraph")
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card = create(:card, post: p)
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    img1 = create(:image, observations: [obs1], slug: "image1")
    img2 = create(:image, observations: [obs2], slug: "image2")

    assert_equal 1, p.decorated.the_rest_of_images.size
    assert_equal "image2", p.decorated.the_rest_of_images[0].slug
  end

  test "properly sort post images" do
    p = create(:post, text: "Text")
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card1 = create(:card, start_time: "6:00", post: p)
    card2 = create(:card, start_time: "7:00", post: p)
    obs1 = create(:observation, taxon: tx1, card: card1)
    obs2 = create(:observation, taxon: tx2, card: card2)
    img1 = create(:image, observations: [obs1], slug: "image1")
    img2 = create(:image, observations: [obs2], slug: "image2")

    assert_equal [img1.id, img2.id], p.images.map(&:id)
  end

end
