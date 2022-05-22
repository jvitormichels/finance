class Installment < ApplicationRecord
  belongs_to :user
  has_many :entries

  before_destroy :handle_installment_entries

  def self.allowed_params
    [
      :name,
      :description,
      :planned_expense
    ]
  end

  def real_expense
    expenses = self.entries.where(type_id: 1).sum(:value)
    incomes = self.entries.where(type_id: 2).sum(:value)
    expenses - incomes
  end

  def handle_installment_entries
    self.entries.update_all(installment_id: nil)
  end
end