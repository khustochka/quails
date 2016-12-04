class PostDecorator

  def initialize(post)
    @post = post
  end

  def title
    OneLineFormatter.apply(@post.title)
  end

  def text
    text_formatter.apply(@post.text)
  end

  private
  def text_formatter
    raise "Method `text_formatter` not implmented."
  end

end
