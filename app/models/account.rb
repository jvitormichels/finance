class Account < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :destroy

  def self.allowed_params
    [
      :name,
      :balance
    ]
  end
end