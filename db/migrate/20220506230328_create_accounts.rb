class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :color
      t.float :balance, default: 0

      t.timestamps
    end
  end
end
