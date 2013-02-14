class PostFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.title)
  end

  def for_site
    @strategy = SiteFormatStrategy.new(@model.text)
    self
  end

  def for_lj
    @strategy = LJFormatStrategy.new(@model.text)
    self
  end

  def text
    self.for_site unless @strategy
    WikiFormatter.new(@strategy).apply
  end

end
