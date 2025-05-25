class SubregionToRegion < ActiveRecord::Migration[8.0]
  class Locus < ActiveRecord::Base
  end

  def change
    Locus.where(loc_type: "subregion").update_all(loc_type: "region")
  end
end
