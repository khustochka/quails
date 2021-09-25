# frozen_string_literal: true

module RecordFinder

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods

    def find_record(options = {})
      only = options[:before]
      raise ArgumentError, "Please define actions explicitly for record finder" unless only
      column = options[:by] || :id
      before_action only: only do
        instance_variable_set(
          "@#{controller_name.singularize}".to_sym,
            controller_name.classify.constantize.send("find_by_#{column}!", params[:id])
        )
      end
    end

  end

end
