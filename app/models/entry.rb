class Entry < ApplicationRecord
  belongs_to :account
  belongs_to :category

  has_one :installment

  def type_to_s(language = '')
    if language == 'pt'
      return "Despesa" if self.type_id == 1
      return "Receita" if self.type_id == 2
    else
      return "expense" if self.type_id == 1
      return "income" if self.type_id == 2
    end
  end

  def self.allowed_params
    [
      :title,
      :description,
      :value,
      :account_id,
      :type_id,
      :category_id,
      :installment_id,
      :date
    ]
  end
end
