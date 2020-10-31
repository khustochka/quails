# frozen_string_literal: true

module LocalizedAttributes
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods

    def localized_attr(*attributes)
      attributes.each do |attr_name|
        define_method attr_name.intern do
          get_localized_attribute(attr_name)
        end
      end
    end

  end

  FALLBACK = %w(uk ru en)

  def get_localized_attribute(attr_name)
    fb = FALLBACK.dup.drop_while { |el| el.intern != I18n.locale }

    nm = read_attribute("#{attr_name}_#{fb.shift}") while nm.blank? && fb.any?
    nm
  end
end
