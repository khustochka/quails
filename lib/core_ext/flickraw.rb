module FlickRaw
  def self.configure(api_key, secret)
    self.api_key = api_key
    self.shared_secret = secret
  end

  def self.configured?
    !!(self.api_key.present? && self.shared_secret.present?)
  end
end
