class ImageFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    WikiFormatter.new(
        SiteFormatStrategy.new(@model.description)
    ).apply
  end

end
