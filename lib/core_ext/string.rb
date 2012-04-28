class String
  def sp_parameterize
    gsub(' ', '_')
  end

  def sp_humanize
    gsub(/[ _+]+/, ' ').capitalize
  end
end
