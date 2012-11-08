module ResearchHelper
  def research_page_header
    [link_to('Research', research_path), @page_title].join(' : ').html_safe
  end

  def locus_check(loc)
    image_tag('/img/check_16x13.png', title: loc, alt: loc)
  end
end
