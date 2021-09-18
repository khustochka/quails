# frozen_string_literal: true

module StoredVariant
  def width
    blob.metadata.fetch(:width, nil)
  end

  def height
    blob.metadata.fetch(:height, nil)
  end
end
