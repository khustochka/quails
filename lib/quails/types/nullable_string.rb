# frozen_string_literal: true

module Quails
  module Types
    class NullableString < ::ActiveModel::Type::String
      private

      # Converts empty string into nil
      def cast_value(value)
        # Need to exclude nil because super converts it to ""
        value.presence.yield_self { |val| super(val) unless val.nil? }
      end
    end
  end
end
