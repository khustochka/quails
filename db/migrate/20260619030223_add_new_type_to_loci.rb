class AddNewTypeToLoci < ActiveRecord::Migration[8.1]
  class Locus < ActiveRecord::Base; end

  def change
    add_column :loci, :new_type, :string, default: nil

    Locus.where(iso_code: "").update_all(iso_code: nil)
    Locus.where(loc_type: "continent").update_all(new_type: "special")
    Locus.where(loc_type: "country").update_all(new_type: "country")
    Locus.where(new_type: nil, ancestry: nil).update_all(new_type: "special")
    Locus.where(loc_type: "region").update_all(new_type: "subdivision1")
    # Only Kyiv
    Locus.where(new_type: nil).where.not(iso_code: nil).update_all(new_type: "subdivision1")
    Locus.where(loc_type: "raion").update_all(new_type: "subdivision2")
    Locus.where(new_type: nil, loc_type: "city").update_all(new_type: "city")
  end
end
