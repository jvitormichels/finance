class CreateInstallments < ActiveRecord::Migration[7.0]
  def change
    create_table :installments do |t|
      t.string :name
      t.string :description
      t.float :planned_expense
      t.integer :user_id

      t.timestamps
    end
  end
end
