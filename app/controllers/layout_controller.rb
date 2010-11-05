module LayoutController

  def self.included(klass)
    class << klass
      alias :old_layout :layout
    end

    klass.extend ClassMethods
    klass.old_layout :get_layout
  end

  module ClassMethods

    def layout(layout, conditions = {})
      before_filter conditions do
        @layout = layout
      end
    end
  end


  private
  def get_layout
    @layout
  end
end