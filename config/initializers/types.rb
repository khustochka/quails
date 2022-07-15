# frozen_string_literal: true

require "quails/types/nullable_string"

ActiveRecord::Type.register(:nullable_string, Quails::Types::NullableString)
