# frozen_string_literal: true

require "core_ext/types/nullable_string"

ActiveRecord::Type.register(:nullable_string, Types::NullableString)
