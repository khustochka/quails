module LayoutController

  def self.included(klass)
    klass.extend ClassMethods
    klass.layout :get_layout
  end

  module ClassMethods

    # TODO: if layout is inherited from ApplicationController and then redefined
    # the parent's unnecessary before_filter remains in the chain (possibly not?)
    def use_layout(layout, conditions = {})
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
