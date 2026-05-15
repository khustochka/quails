# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    transient do
      sequence(:slug) { |n| "post_#{n}" }
      legacy_slug { nil }
      topic { "OBSR" }
      cover_image_slug { nil }
      publish_to_facebook { false }
    end

    title { "Test Post" }
    body { <<~TEXT }
      This is a post text.

      It must be multiline.
    TEXT
    status { "OPEN" }
    lang { "uk" }

    # Reuse an existing PostCore when a slug matches (so two siblings can be
    # built with the same slug); otherwise build a fresh one. Core-level
    # attributes (legacy_slug, topic, cover_image_slug, publish_to_facebook)
    # are applied to whichever core wins.
    post_core do
      slug_value = slug
      core = PostCore.find_or_initialize_by(slug: slug_value)
      core.legacy_slug = legacy_slug if legacy_slug
      core.topic = topic
      core.cover_image_slug = cover_image_slug if cover_image_slug
      core.publish_to_facebook = publish_to_facebook
      core
    end
  end
end
