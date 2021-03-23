module NewDecorators
  class PostDecorator < BaseDecorator
    attr_reader :post

    def self.model_name
      :post
    end

    # FIXME: tags or no tags?
    def title
      @context.format_one_line(post.title)
    end
  end
end
