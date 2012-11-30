class Object
  def if_present(&block)
    unless blank?
      tap &block
    end
  end
end
