module FormattedModel

  MAPPING = {
      Post => PostFormatter,
      Image => ImageFormatter,
      Comment => CommentFormatter,
      Observation => ObservationFormatter
  }

  def formatted
    MAPPING.fetch(self.class).new(self)
  end
end
