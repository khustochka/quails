# frozen_string_literal: true

module MapHelper
  # Global map intensity ramp, from few checklists to many. Reuses the public
  # map's cluster colours (.marker-cluster) with a blue stage added. Passed to
  # the map JS so the legend and the markers cannot drift apart.
  INTENSITY_RAMP = %w(#6ecc39 #3aa0d8 #f0c20c #f18017).freeze

  def map_enabled
    !Rails.env.test?
  end
end
