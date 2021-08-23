# frozen_string_literal: true

class ExternalAsset  < ApplicationRecord
  EXTERNAL_SERVICES = %w[ flickr youtube ]

  belongs_to :media, inverse_of: :external_asset, touch: true
  has_many :external_asset_variants, inverse_of: :external_asset

  # For Flickr photos analyzed means variants are created
  store :metadata, accessors: [ :analyzed, :width, :height ], coder: ActiveRecord::Coders::JSON

  validates :service_name, presence: true, inclusion: { in: EXTERNAL_SERVICES }
  validates :external_key, presence: true, uniqueness: { scope: :service_name }
end
