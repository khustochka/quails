module ResearchHelper
  def research_page_header
    capture do
      concat link_to('Research', research_path)
      concat " : "
      concat @page_title
    end
  end

  def locus_check(loc)
    content_tag(:span, "", class: "fas fa-check green-check", title: loc, alt: loc)
  end
end
