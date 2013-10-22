module FlickRaw
  def self.configure(api_key, secret)
    self.api_key = api_key
    self.shared_secret = secret
  end

  def self.configured?
    !!(self.api_key.present? && self.shared_secret.present?)
  end

  class ResponseList < Response

    # Adding `concat` method for concatenating result lists
    def concat(other_list)
      @a.concat(other_list.to_a)
    end


  end

end
