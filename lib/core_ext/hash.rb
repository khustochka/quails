# frozen_string_literal: true

class Hash
  def &(other)
    delete_if { |k, v| v != other[k] }
  end
end
