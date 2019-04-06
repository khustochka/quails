class AddUnreportedBirdSp < ActiveRecord::Migration[4.2]
  def up
    Taxon.create!(
             name_sci: "Unreported bird sp.",
             name_en: "Unreported bird sp.",
             index_num: (Taxon.maximum(:index_num) || 0) + 1,
             category: "spuh",
             ebird_code: "unrepbirdsp"
    )
  end

  def down
    Taxon.where(name_sci: "Unreported bird sp.").first.destroy
  end
end
