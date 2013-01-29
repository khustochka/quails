module ChecklistsHelper

  def convert_status(str)
    OneLineFormatter.apply(str)
  end

end
