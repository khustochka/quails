class ChecklistsController < ApplicationController
  def show
    @locus = Locus.find_by_slug(params[:slug])
    @checklist = @locus.checklist
  end
end