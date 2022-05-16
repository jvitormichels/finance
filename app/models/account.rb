class Account < ApplicationRecord
  has_many :entries, dependent: :destroy
end