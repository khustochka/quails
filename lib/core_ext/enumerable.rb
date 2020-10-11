# frozen_string_literal: true

module Enumerable
  def fast_index_by
    if block_given?
      result = {}
      each { |elem| result[yield(elem)] ||= elem }
      result
    else
      to_enum(:index_by) { size if respond_to?(:size) }
    end
  end
end
