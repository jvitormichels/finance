class Entry < ApplicationRecord
  belongs_to :account

  def self.allowed_params
    [
      :title,
      :description,
      :value,
      :account_id
    ]
  end
end
