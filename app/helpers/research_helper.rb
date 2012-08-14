module ResearchHelper
  def research_page_header
    [link_to('Research', research_path), @page_title].join(' : ').html_safe
  end
end
