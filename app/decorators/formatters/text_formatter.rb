module Formatters
  class TextFormatter

    def initialize(strategy)
      @strategy = strategy
    end

    def apply(text)
      formatters.inject(text) do |output, formatter|
        send(formatter, output)
      end
    end

    private
    def formatters
      [
          :apply_wiki,
          :apply_textile,
          :apply_autolink
      ]
    end

    def apply_wiki(input)
      @strategy.apply(input)
    end

    def apply_textile(input)
      RedCloth.new(input).to_html
    end

    def apply_autolink(input)
      Rinku.auto_link(input, :urls)
    end

  end
end
