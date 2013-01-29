class ModelFormatter
  def initialize(model)
    @model = model
  end

  def title
    TitleFormatter.new(@model.title).to_html
  end
end
