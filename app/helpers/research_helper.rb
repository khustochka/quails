module ResearchHelper
  def research_page_header
    [link_to('Research', research_path), @page_title].join(' : ').html_safe
  end

  def locus_check(loc)
    content_tag(:span, "", class: "fa fa-check green-check", title: loc, alt: loc)
  end
end
