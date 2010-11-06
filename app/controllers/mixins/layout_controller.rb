module LayoutController

  def self.included(klass)
    class << klass
      alias :__layout__ :layout
    end

    klass.extend ClassMethods
    klass.__layout__ :get_layout
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