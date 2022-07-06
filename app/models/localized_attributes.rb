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

  FALLBACK = { en: [], uk: %w(en ru), ru: %w(uk en) }

  def get_localized_attribute(attr_name)
    fb = FALLBACK[I18n.locale.to_sym].dup.unshift(I18n.locale)
    nm = nil
    nm = self["#{attr_name}_#{fb.shift}"] while nm.blank? && fb.any?
    nm
  end
end
