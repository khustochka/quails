class PostFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.title)
  end

  def for_site
    @strategy = SiteFormatStrategy.new
    self
  end

  def for_lj
    @strategy = LJFormatStrategy.new
    self
  end

  def text
    self.for_site unless @strategy
    WikiFormatter.new(@strategy).apply(@model.text)
  end

end
