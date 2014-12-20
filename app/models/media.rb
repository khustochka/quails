class Media < ActiveRecord::Base
  has_and_belongs_to_many :observations

  serialize :assets_cache, ImageAssetsArray
end
