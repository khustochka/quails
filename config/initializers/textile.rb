# Workaround for haml + textile
# haml fails to load maruku and does not try textile
require "haml/filters/textile"
