module NewLifelist
  class FirstSeen < Base

    def preselect_ordering
      "ASC"
    end

    def aggregation_operator
      "MIN"
    end

  end
end
