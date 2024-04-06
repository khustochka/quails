# frozen_string_literal: true

module RecordFinder
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def find_record(before: nil, by: :id, model: nil, var: nil)
      raise ArgumentError, "Please define actions explicitly for record finder via before key" unless before

      # model: Can be string or class
      model_name = model || controller_name.classify
      variable = var || controller_name.singularize
      unless variable.start_with?("@")
        variable = "%s%s" % ["@", variable]
      end
      variable = variable.to_sym
      before_action only: before do
        instance_variable_set(
          variable,
          model_name.constantize.public_send(:find_by!, { by => params[:id] })
        )
      end
    end
  end
end
