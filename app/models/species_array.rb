module SpeciesArray
  def group_by_taxonomy
    to_a.group_by {|sp| {:order => sp.order, :family => sp.family} }.each do |key, v|
      yield key[:order], key[:family], v
    end
  end
end
