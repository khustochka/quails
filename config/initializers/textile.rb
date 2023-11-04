# frozen_string_literal: true

require "haml/filters/textile"

Haml::Filters.__send__(:register, :textile, Haml::Filters::Textile)
