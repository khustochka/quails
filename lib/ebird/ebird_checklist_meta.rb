class EbirdChecklistMeta
  # Represents imported checklist row
  include ActiveModel::Model

  attr_accessor :ebird_id, :time, :location, :county, :state_prov, :card

  def locus_id
    Locus.find_by_name_en(location)&.id
  end

  def parent_id
    Locus.find_by_name_en(county)&.id
  end
end
