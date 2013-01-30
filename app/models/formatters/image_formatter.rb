class ImageFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.public_title)
  end

end
