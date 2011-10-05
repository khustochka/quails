class Lifer < Species
  attr_accessor :post

  def count
    attributes['times_seen'].to_i
  end

  def first_seen_date
    @first_seen_date ||= Date.parse(attributes['first_seen'])
  end
end