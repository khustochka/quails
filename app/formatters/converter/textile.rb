# frozen_string_literal: true

module Converter
  class Textile
    class << self
      def one_line(str)
        RedCloth.new(str, [:lite_mode]).to_html.html_safe # rubocop:disable Rails/OutputSafety
      end

      def paragraph(str)
        RedCloth.new(str).to_html
      end
    end
  end
end
