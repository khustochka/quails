# frozen_string_literal: true

# Context-based month name and day name switching for Russian
#
# Названия месяцев и дней недели в зависимости от контекста ("1 декабря", но "Декабрь 1985")

# Regexp machers for context-based russian month names and day names translation
LOCALIZE_ABBR_MONTH_NAMES_MATCH = /(%\-?d|%e)(.*)(%b)/
LOCALIZE_MONTH_NAMES_MATCH = /(%\-?d|%e)(.*)(%B)/
LOCALIZE_STANDALONE_ABBR_DAY_NAMES_MATCH = /^%a/
LOCALIZE_STANDALONE_DAY_NAMES_MATCH = /^%A/

RULES = {
  date: {
    abbr_day_names: lambda { |_key, **options|
      if options[:format] && options[:format] =~ LOCALIZE_STANDALONE_ABBR_DAY_NAMES_MATCH
        :"date.common_abbr_day_names"
      else
        :"date.standalone_abbr_day_names"
      end
    },
    day_names: lambda { |_key, **options|
      if options[:format] && options[:format] =~ LOCALIZE_STANDALONE_DAY_NAMES_MATCH
        :"date.standalone_day_names"
      else
        :"date.common_day_names"
      end
    },
    abbr_month_names: lambda { |_key, **options|
      if options[:format] && options[:format] =~ LOCALIZE_ABBR_MONTH_NAMES_MATCH
        :"date.common_abbr_month_names"
      else
        :"date.standalone_abbr_month_names"
      end
    },
    month_names: lambda { |_key, **options|
      if options[:format] && options[:format] =~ LOCALIZE_MONTH_NAMES_MATCH
        :"date.common_month_names"
      else
        :"date.standalone_month_names"
      end
    },
  },
}

{
  uk: RULES,
  ru: RULES,
}
