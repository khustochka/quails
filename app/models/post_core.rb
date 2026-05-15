# frozen_string_literal: true

class PostCore < ApplicationRecord
  class LJData < Struct.new(:post_id, :url)
    def blank?
      post_id.blank? || url.blank?
    end
  end

  TOPICS = %w(OBSR NEWS SITE)

  serialize :lj_data, type: LJData, coder: YAML

  has_many :posts, dependent: :restrict_with_error, inverse_of: :post_core
  has_many :cards, -> { order(:observ_date, :locus_id) }, dependent: :nullify, inverse_of: :post_core
  has_many :observations, dependent: :nullify, inverse_of: :post_core

  validates :slug, presence: true, uniqueness: true, length: { maximum: 64 }, format: /\A[\w\-]+\Z/
  validates :legacy_slug, uniqueness: true, allow_nil: true, length: { maximum: 64 }
  validates :topic, inclusion: TOPICS, presence: true, length: { maximum: 4 }

  validate :check_cover_image_slug_or_url

  def lj_url
    @lj_url ||= lj_data.url
  end

  private

  def check_cover_image_slug_or_url
    return if cover_image_slug.blank?
    return if cover_image_slug.to_s.match?(%r{\Ahttps?://})
    return if Image.find_by(slug: cover_image_slug)

    errors.add(:cover_image_slug, "should be image slug or external URL.")
  end
end
