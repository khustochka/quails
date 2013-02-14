class ImageFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    WikiFormatter.new(@model.description).for_site
  end

end
