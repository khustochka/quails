class MyObservations < Observation

  # This class represents only observations that are mine and identified

  default_scope mine.identified

end