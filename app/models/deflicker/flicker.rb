module Deflicker
  class Flicker
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    field :flickr_id, type: String
    field :public, type: Boolean
    field :uploaded_at, type: Time
    field :removed, type: Boolean
    field :slug, type: String
    field :on_s3, type: Boolean

    has_and_belongs_to_many :journal_entries

    def ispublic=(val)
      self.public = val != 0
    end

    def dateupload=(val)
      self.uploaded_at = Time.at(val.to_i)
    end

    def image
      Image.find_by(slug: slug)
    end
  end
end
