module LayoutController

  def self.included(klass)
    class << klass
      alias_method :__layout__, :layout
    end

    klass.extend ClassMethods
    klass.__layout__ :get_layout
  end

  module ClassMethods

    # TODO: if layout is inherited from ApplicationController and then redefined
    # the parent's unnecessary before_filter remains in the chain (possibly not?)
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