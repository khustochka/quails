class PostFormatter < ModelFormatter

  def title
    OneLineFormatter.apply(@model.title)
  end

end
