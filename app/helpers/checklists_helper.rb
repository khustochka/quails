module ChecklistsHelper

  def avibase_list_url(region, list = 'clements', lang = 'EN')
    "http://avibase.bsc-eoc.org/checklist.jsp?region=#{region}&list=#{list}&lang=#{lang}"
  end

end