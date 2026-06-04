# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "post factory is valid" do
    assert_predicate create(:post), :valid?
    assert_predicate create(:post), :valid?
  end

  test "legacy Post::LJData YAML in posts.lj_data deserializes" do
    yaml = "--- !ruby/struct:Post::LJData\npost_id: '42'\nurl: https://example.com/42.html\n"
    blogpost = create(:post)
    Post.connection.exec_update(
      "UPDATE posts SET lj_data = $1 WHERE id = $2",
      "raw lj_data",
      [yaml, blogpost.id]
    )
    blogpost.reload
    assert_equal "42", blogpost.lj_data.post_id
    assert_equal "https://example.com/42.html", blogpost.lj_url
  end

  test "shout can have an empty title" do
    blogpost = build(:post, title: "", post_core: build(:post_core, shout: true))
    assert blogpost.save
  end

  test "do not save post with existing language in the same core" do
    core = create(:post_core)
    create(:post, post_core: core, lang: "uk")
    blogpost = build(:post, post_core: core, lang: "uk")
    assert_not_predicate blogpost, :valid?
  end

  test "two translations can share one PostCore" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    en_post = create(:post, post_core: core, lang: "en")
    assert_predicate en_post, :valid?
    assert_equal uk_post.post_core_id, en_post.post_core_id
  end

  test "destroying one translation leaves the core and its siblings intact" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    en_post = create(:post, post_core: core, lang: "en")
    uk_post.destroy!
    assert PostCore.exists?(en_post.post_core_id)
    assert en_post.reload
  end

  test "destroying one translation does not affect cards/observations on the core" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    en_post = create(:post, post_core: core, lang: "en")
    card = create(:card, post_core: core)
    obs = create(:observation, post_core: core)
    uk_post.destroy!
    assert_equal en_post.post_core_id, card.reload.post_core_id
    assert_equal en_post.post_core_id, obs.reload.post_core_id
  end

  test "localized_versions does not include self as sibling" do
    uk_post = create(:post, lang: "uk")
    versions = uk_post.localized_versions
    assert_nil versions[:en]
  end

  test "localized_versions returns dedicated uk and ru posts when both exist" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    ru_post = create(:post, post_core: core, lang: "ru")
    en_post = create(:post, post_core: core, lang: "en")
    versions = uk_post.localized_versions
    assert_equal uk_post, versions[:uk]
    assert_equal ru_post, versions[:ru]
    assert_equal en_post, versions[:en]
  end

  test "localized_versions falls back to ru post when no uk post exists" do
    ru_post = create(:post, lang: "ru")
    versions = ru_post.localized_versions
    assert_equal ru_post, versions[:uk]
    assert_equal ru_post, versions[:ru]
  end

  test "localized_versions falls back to uk post when no ru post exists" do
    uk_post = create(:post, lang: "uk")
    versions = uk_post.localized_versions
    assert_equal uk_post, versions[:uk]
    assert_equal uk_post, versions[:ru]
  end

  test "localized_for returns en sibling for en locale when it exists" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    en_post = create(:post, post_core: core, lang: "en")
    result = Post.localized_for([core], :en)
    assert_equal en_post, result[uk_post.post_core_id]
  end

  test "localized_for returns nil for en locale when no en sibling exists" do
    uk_post = create(:post, lang: "uk")
    result = Post.localized_for([uk_post.post_core], :en)
    assert_nil result[uk_post.post_core_id]
  end

  test "localized_for prefers uk over ru for uk locale" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    create(:post, post_core: core, lang: "ru")
    result = Post.localized_for([core], :uk)
    assert_equal uk_post, result[uk_post.post_core_id]
  end

  test "localized_for falls back to ru for uk locale when no uk sibling exists" do
    ru_post = create(:post, lang: "ru")
    result = Post.localized_for([ru_post.post_core], :uk)
    assert_equal ru_post, result[ru_post.post_core_id]
  end

  test "localized_for falls back to uk for ru locale when no ru sibling exists" do
    uk_post = create(:post, lang: "uk")
    result = Post.localized_for([uk_post.post_core], :ru)
    assert_equal uk_post, result[uk_post.post_core_id]
  end

  test "localized_for excludes posts outside the given scope" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    create(:post, post_core: core, lang: "en", status: "PRIV")
    result = Post.localized_for([core], :en, scope: Post.public_posts)
    assert_nil result[uk_post.post_core_id]
  end

  test "localized_for handles empty input" do
    assert_equal({}, Post.localized_for([], :en))
  end

  test "do not save post with empty title" do
    blogpost = build(:post, title: "")
    assert_not_predicate blogpost, :valid?
  end

  test "set post's face_date to current when creating" do
    time, blogpost = freeze_time do
      [Time.current, create(:post)]
    end
    assert_equal time.strftime("%F %T"), blogpost.face_date.strftime("%F %T")
  end

  test "set post's face_date to current when saving with empty value" do
    blogpost = create(:post, updated_at: "2008-01-01 02:02:02", face_date: "2008-01-01")

    time = freeze_time do
      blogpost.update(face_date: "")
      Time.current
    end
    blogpost.reload
    assert_equal time.strftime("%F %T"), blogpost.face_date.strftime("%F %T")
  end

  test "calculate previous month correctly (one having posts) even for month with no posts" do
    create(:post, face_date: "2010-02-06 13:14:15")
    create(:post, face_date: "2009-11-06 13:14:15")
    create(:post, face_date: "2009-10-06 13:14:15")
    assert_nil Post.prev_month("2009", "10")
    assert_equal({ month: "11", year: "2009" }, Post.prev_month("2009", "12"))
    assert_equal({ month: "11", year: "2009" }, Post.prev_month("2010", "01"))
    assert_equal({ month: "11", year: "2009" }, Post.prev_month("2010", "02"))
  end

  test "calculate next month correctly (one having posts) even for month with no posts" do
    create(:post, face_date: "2010-02-06 13:14:15")
    create(:post, face_date: "2009-11-06 13:14:15")
    create(:post, face_date: "2010-03-06 13:14:15")
    assert_equal({ month: "02", year: "2010" }, Post.next_month("2009", "11"))
    assert_equal({ month: "02", year: "2010" }, Post.next_month("2009", "12"))
    assert_equal({ month: "02", year: "2010" }, Post.next_month("2010", "01"))
    assert_nil Post.next_month("2010", "03")
  end

  test "destroying a post does not delete its observations; they remain attached to its core" do
    blogpost = create(:post, face_date: "2010-02-06 13:14:15")
    observation = create(:observation, post_core: blogpost.post_core)
    core_id = blogpost.post_core_id
    blogpost.destroy
    assert observation.reload
    assert_equal core_id, observation.post_core_id
  end

  test "face date is treated as timezone-less" do
    blogpost = create(:post, face_date: "2013-01-01 00:30:00") # risky time (different days in GMT and EEST)
    assert_includes(Post.year(2013).ids, blogpost.id)
    assert_not_includes(Post.year(2012).ids, blogpost.id)
  end

  test "calculate next and previous months correctly (last day in mind)" do
    create(:post, face_date: "2011-01-20 12:30:00")
    create(:post, face_date: "2011-01-31 23:53:00") # last day and risky time
    create(:post, face_date: "2011-02-01 00:30:00") # risky time (different days in GMT and EEST)
    create(:post, face_date: "2011-02-15 12:53:00")
    assert_equal({ month: "02", year: "2011" }, Post.next_month("2011", "01"))
    assert_equal({ month: "01", year: "2011" }, Post.prev_month("2011", "02"))
  end

  test "adding image to post should touch posts`s updated_at via post_core" do
    p = create(:post)
    saved_date = p.post_core.updated_at

    travel 1.minute do
      @obs = create(:observation, post_core: p.post_core)
    end

    travel 2.minutes do
      create(:image, observation_ids: [@obs.id])
      p.post_core.reload
      assert p.post_core.updated_at.to_i > saved_date.to_i
    end
  end

  test "moving image to another observation of the same card should touch post_core's updated_at" do
    p = create(:post)
    saved_date = p.post_core.updated_at
    card = create(:card, post_core: p.post_core)

    o = create(:observation, card: card)
    i = create(:image, observations: [o])

    o2 = create(:observation, card: card)

    travel 1.minute do
      # Have to refind it to clear association cache
      img = Image.find(i.id)

      img.update({ observation_ids: [o2.id] })

      p.post_core.reload
      assert p.post_core.updated_at.to_i > saved_date.to_i
    end
  end

  test "destroying image should touch post_core's updated_at" do
    p = create(:post)
    saved_date = p.post_core.updated_at
    card = create(:card, post_core: p.post_core)

    o = create(:observation, card: card)
    i = create(:image, observations: [o])

    travel 1.minute do
      img = Image.find(i.id)
      img.destroy

      p.post_core.reload
      assert p.post_core.updated_at.to_i > saved_date.to_i
    end
  end

  test "moving card out of the post should touch post_core" do
    p = create(:post)
    saved_date = p.post_core.updated_at
    card = create(:card, post_core: p.post_core)

    travel 1.minute do
      c = Card.find card.id
      c.post_core = nil
      c.save!

      p.post_core.reload
      assert p.post_core.updated_at.to_i > saved_date.to_i
    end
  end

  test "proper post species list for observations attached to post" do
    p = create(:post)
    c = create(:card, post_core: p.post_core)
    create(:observation, card: c, taxon: taxa(:hirrus))
    create(:observation, post_core: p.post_core, taxon: taxa(:pasdom))

    assert_equal 2, p.species.to_a.size
  end

  test "proper post images list for observations attached to post" do
    p = create(:post)
    c = create(:card, post_core: p.post_core)
    o = create(:observation, card: c, taxon: taxa(:hirrus))
    o2 = create(:observation, post_core: p.post_core, taxon: taxa(:pasdom))
    create(:image, observations: [o])
    create(:image, observations: [o2])

    assert_equal 2, p.images.to_a.size
  end

  test "post images should not be duplicated (if multi-species)" do
    p = create(:post)
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card = create(:card, observ_date: "2008-07-01", post_core: p.post_core)
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    create(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])

    assert_equal 1, p.images.to_a.size
  end

  test "new species count should not be duplicated if new species was seen twice in a day" do
    p = create(:post)
    card1 = create(:card, observ_date: "2015-04-27", post_core: p.post_core)
    create(:observation, taxon: taxa(:hirrus), card: card1)
    card2 = create(:card, observ_date: "2015-04-27", post_core: p.post_core)
    create(:observation, taxon: taxa(:hirrus), card: card2)
    assert_equal 1, p.lifer_species_ids.size
  end

  test "do not show on homepage the images that are already in post body" do
    p = create(:post, body: "First paragraph\n\n{{^image1}}\n\nLast paragraph")
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card = create(:card, post_core: p.post_core)
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    create(:image, observations: [obs1], slug: "image1")
    create(:image, observations: [obs2], slug: "image2")

    assert_equal 1, p.decorated.the_rest_of_images.size
    assert_equal "image2", p.decorated.the_rest_of_images[0].slug
  end

  test "properly sort post images" do
    p = create(:post, body: "Text")
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card1 = create(:card, start_time: "6:00", post_core: p.post_core)
    card2 = create(:card, start_time: "7:00", post_core: p.post_core)
    obs1 = create(:observation, taxon: tx1, card: card1)
    obs2 = create(:observation, taxon: tx2, card: card2)
    img1 = create(:image, observations: [obs1], slug: "image1")
    img2 = create(:image, observations: [obs2], slug: "image2")

    assert_equal [img1.id, img2.id], p.images.map(&:id)
  end

  test "cache key is changed after commenting on post" do
    p = create(:post, body: "Text")
    key1 = p.cache_key
    create(:comment, post: p)
    assert_not_equal p.reload.cache_key, key1
  end

  test "cache key changes when post_core is updated" do
    p = create(:post, body: "Text")
    key1 = p.cache_key
    travel 1.minute do
      p.post_core.update!(cover_image_slug: nil, topic: "NEWS")
      p.reload
      assert_not_equal key1, p.cache_key
    end
  end
end
