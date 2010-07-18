class Post < ActiveRecord::Base
  validates_presence_of :code, :title, :topic, :status

  def to_param
    code
  end

end
