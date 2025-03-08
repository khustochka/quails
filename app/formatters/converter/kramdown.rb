# frozen_string_literal: true

module Converter
  class Kramdown
    class << self
      def one_line(text)
        # Remove opening and closing P tags
        paragraph(text)[3..-6]
      end

      def paragraph(text)
        ::Kramdown::Document.new(text, input: "GFM").to_html
      end
    end
  end
end
