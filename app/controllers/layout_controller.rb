module LayoutController
  
  def self.included(klass)
    klass.extend ClassMethods
    klass.old_layout :choose_layout
  end

  module ClassMethods
    include AbstractController::Layouts::ClassMethods
    alias :old_layout :layout

    def layout(layout, conditions = {})
      before_filter conditions do
        @layout = layout
      end
    end
    
  end

  private
  def choose_layout
    @layout
  end
end