module Deflicker
  class Flicker
    include Mongoid::Document
    include Mongoid::Attributes::Dynamic

    field :flickr_id, type: String
    field :ispublic, type: Integer

    def public?
      ispublic != 0
    end
  end
end
