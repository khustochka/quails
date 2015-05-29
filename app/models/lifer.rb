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

  def seen_abroad?
    (first_seen >= Date.new(2010, 07, 19) && first_seen <= Date.new(2011, 05, 15)) ||
        (first_seen >= Date.new(2013, 11, 10) && first_seen <= Date.new(2013, 11, 20)) ||
        (first_seen >= Date.new(2014, 04, 25) && first_seen <= Date.new(2014, 05, 01)) ||
        first_seen > Date.new(2014, 06, 18)
  end
end
