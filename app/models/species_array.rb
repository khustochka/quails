module SpeciesArray
  def group_by_family
    to_a.group_by {|sp| {:order => sp.order, :family => sp.family} }
  end
end
