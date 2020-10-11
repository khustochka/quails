# frozen_string_literal: true

class CommentScreened
  attr_reader :path, :id

  def initialize(attr)
    @path = attr[:path]
    @id = attr[:id]
  end

  def to_partial_path
    'comments/screened'
  end
end
