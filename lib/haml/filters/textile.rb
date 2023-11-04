# frozen_string_literal: true

module Haml
  class Filters
    class Textile < TiltBase
      def compile(node)
        require "tilt/redcloth" if explicit_require?("textile")
        compile_with_tilt(node, "textile")
      end
    end
  end
end
