class Category < ApplicationRecord
  has_many :entries

  def self.allowed_params
    [
      :name
    ]
  end
end