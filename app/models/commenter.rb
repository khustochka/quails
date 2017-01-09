class Commenter < ApplicationRecord
  has_many :comments

  serialize :auth_hash, HashWithIndifferentAccess

  def admin?
    provider == "admin"
  end

  def sane_url
    uri = Addressable::URI.heuristic_parse(url)
    if uri && uri.scheme.in?(%w[http https])
      uri.to_str
    else
      nil
    end
  end
end
