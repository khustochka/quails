class MyObservation < Observation

  # This class represents only observations that are mine and identified

  default_scope where(:mine => true).identified

end