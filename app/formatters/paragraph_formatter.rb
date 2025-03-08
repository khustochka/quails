# frozen_string_literal: true

class ParagraphFormatter
  class << self
    def apply(str, converter = Converter::Textile)
      Rinku.auto_link(converter.paragraph(str), :urls)
    end
  end
end
