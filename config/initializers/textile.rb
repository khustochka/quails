# frozen_string_literal: true

# Workaround for haml + textile
# haml fails to load maruku and does not try textile
require "haml/filters/textile"
