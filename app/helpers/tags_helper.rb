module TagsHelper
  def header(n, text)
    content_tag("h#{n}", text)
  end
end