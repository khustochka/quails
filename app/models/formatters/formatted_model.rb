module FormattedModel

  MAPPING = {
      Post => PostFormatter,
      Image => ImageFormatter,
      Comment => CommentFormatter,
      Observation => ObservationFormatter,
      Card => CardFormatter,
      Page => PageFormatter
  }

  def formatted(metadata = {})
    MAPPING.fetch(self.class).new(self, metadata)
  end
end
