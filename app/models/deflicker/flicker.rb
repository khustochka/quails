module Deflicker
  class Flicker
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    field :flickr_id, type: String
    field :public, type: Boolean
    field :uploaded_at, type: Time
    field :removed, type: Boolean

    def public?
      public
    end

    def ispublic=(val)
      self.public = val != 0
    end

    def dateupload=(val)
      self.uploaded_at = Time.at(val.to_i)
    end
  end
end
