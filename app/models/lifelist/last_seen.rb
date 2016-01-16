module Lifelist
  class LastSeen < Base

    def preselect_ordering
      "DESC"
    end

    def aggregation_operator
      "MAX"
    end

  end
end
