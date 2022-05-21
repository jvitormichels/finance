class Category < ApplicationRecord
  def self.allowed_params
    [
      :name
    ]
  end
end