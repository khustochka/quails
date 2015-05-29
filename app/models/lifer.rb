class Lifer < Species
  attr_accessor :post, :last_post, :card, :last_card

  def count
    times_seen.to_i if respond_to? :times_seen
  end

  def first_seen_date
    @first_seen_date ||= first_seen if respond_to? :first_seen
  end

  def last_seen_date
    @last_seen_date ||= last_seen if respond_to? :last_seen
  end
end
