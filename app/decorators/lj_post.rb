class LJPost < PostDecorator

  def title
    # SafeBuffer breaks 'livejournal' gem
    # We have to `unsafe` the title with 'to_str'
    super.to_str
  end

  private
  def text_formatter
    TextFormatter.new(LJPostStrategy.new)
  end

end
