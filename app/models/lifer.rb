class Lifer < Species
  attr_accessor :post

  def count
    times_seen.to_i
  end

  def date
    Date.parse(first_seen)
  end
end