class ImageFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    WikiFormatter.new(SiteFormatStrategy.new).apply(@model.description)
  end

end
