class PostFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.title)
  end

  def for_site
    @formatting_method = :for_site
    self
  end

  def for_lj
    @formatting_method = :for_lj
    self
  end

  def text
    WikiFormatter.new(@model.text).send(@formatting_method)
  end

end
