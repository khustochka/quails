class Correction < ApplicationRecord
  validates :model_classname, :query, :sort_column, presence: true

  def results
    # Adding id sorting for strict order
    records.order(sort_column, :id)
  end

  def count
    records.count
  end

  private

  def model_class
    model_classname.constantize
  end

  def records
    model_class.where(query)
  end
end
