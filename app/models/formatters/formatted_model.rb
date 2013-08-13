module FormattedModel

  MAPPING = {
      Post => PostFormatter,
      Image => ImageFormatter,
      Comment => CommentFormatter,
      Observation => ObservationFormatter,
      Card => CardFormatter
  }

  def formatted(metadata = {})
    MAPPING.fetch(self.class).new(self, metadata)
  end
end
