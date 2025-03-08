# frozen_string_literal: true

module OneLineFormatter
  class << self
    def apply(str, converter = Converter::Textile)
      converter.one_line(str)
    end
  end
end
