class UpdateLocusTypes < ActiveRecord::Migration[8.0]
  class Locus < ActiveRecord::Base
  end

  def change
    Locus.where(loc_type: %w(subcountry state oblast)).update_all(loc_type: "subregion")
  end
end

