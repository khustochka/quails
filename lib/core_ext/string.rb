class String
  def sp_parameterize
    gsub(' ', '_')
  end

  def sp_humanize
    gsub(/[ _+]+/, ' ').tap do |s|
      return s.capitalize unless s[0] == '-'
    end
  end
end