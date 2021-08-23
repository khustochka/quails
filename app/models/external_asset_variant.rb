# frozen_string_literal: true

class ExternalAssetVariant < ApplicationRecord
  belongs_to :external_asset, touch: true, inverse_of: :external_asset_variants

  store :metadata, accessors: [ :width, :height, :url ], coder: ActiveRecord::Coders::JSON

  validates :variation_key, presence: true, uniqueness: { scope: :external_asset_id }
end
