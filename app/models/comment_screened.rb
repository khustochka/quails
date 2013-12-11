class CommentScreened
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def to_partial_path
    'comments/screened'
  end
end
