# frozen_string_literal: true

module CorrectionsHelper
  def inject_correction_field
    hidden_field_tag "correction", @correction&.id
  end
end
