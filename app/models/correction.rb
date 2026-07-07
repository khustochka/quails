# frozen_string_literal: true

class Correction < ApplicationRecord
  # To add a model you need to include CorrectableConcern in the controller
  # and add `inject_correction_field` to its form.
  CORRECTABLE_MODELS = %w(Post Locus)

  DANGEROUS_SQL_PATTERN = /;\s*\b(DROP|DELETE|TRUNCATE|ALTER|UPDATE|INSERT|CREATE|GRANT|REVOKE)\b/i

  validates :model_classname, :query, :sort_column, presence: true
  validates :model_classname, inclusion: CORRECTABLE_MODELS
  validate :query_validity
  validate :sort_column_is_valid_column
  validate :query_is_not_destructive

  def results
    if query_valid?
      # Adding id sorting for strict order
      records.order(sort_column, :id)
    else
      model_class.none
    end
  end

  # Maybe invalid on creation, or later, when a column is removed, for example
  def query_valid?
    records.first
    true
  rescue ActiveRecord::StatementInvalid, PG::Error
    false
  end

  def count
    results.count
  end

  def after(record)
    results.where("#{sort_column_with_table} > ? OR (#{sort_column_with_table} = ? AND #{table}.id > ?)", record[sort_column], record[sort_column], record.id)
  end

  def next_after(record)
    after(record).first
  end

  private

  def model_class
    model_classname.constantize
  end

  def records
    model_class.where(query)
  end

  def table
    model_class.table_name
  end

  def sort_column_with_table
    [table, sort_column].join(".")
  end

  # Cannot reuse query_valid? because we need to extract error message
  def query_validity
    records.first
  rescue ActiveRecord::StatementInvalid, PG::Error => e
    errors.add(:base, "Resulting query is invalid: #{e.message}")
  end

  def sort_column_is_valid_column
    return if model_classname.blank?

    unless sort_column.in?(model_class.column_names)
      errors.add(:sort_column, "must be a valid column name")
    end
  rescue NameError
    # model_classname invalid — handled by inclusion validation
  end

  def query_is_not_destructive
    if query.present? && query.match?(DANGEROUS_SQL_PATTERN)
      errors.add(:query, "must not contain destructive SQL statements")
    end
  end
end
