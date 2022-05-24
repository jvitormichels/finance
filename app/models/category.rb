class Category < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :destroy

  def self.allowed_params
    [
      :name
    ]
  end

  def total_expenses
    self.entries.where(type_id: 1).sum(:value)
  end

  def total_occurrences
    self.entries.count
  end
end