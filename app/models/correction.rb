# frozen_string_literal: true

class Correction < ApplicationRecord
  # To add a model you need to modify the controller and form
  CORRECTABLE_MODELS = %w(Post)

  validates :model_classname, :query, :sort_column, presence: true
  validates :model_classname, inclusion: CORRECTABLE_MODELS
  validate :query_validity

  def results
    # Adding id sorting for strict order
    records.order(sort_column, :id)
  end

  def count
    records.count
  end

  def next_after(record)
    results.where("#{sort_column_with_table} > ? OR (#{sort_column_with_table} = ? AND #{table}.id > ?)", record[sort_column], record[sort_column], record.id).first
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

  def query_validity
    results.first
  rescue ActiveRecord::StatementInvalid => e
    errors.add(:base, "Resulting query is invalid: #{e.message}")
  end
end
