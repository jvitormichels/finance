class Account < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :destroy

  before_create :set_user

  def self.allowed_params
    [
      :name,
      :color,
      :balance
    ]
  end

  def set_user
    self.user_id = current_user.id
  end
end