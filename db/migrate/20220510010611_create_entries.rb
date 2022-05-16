class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.string :title
      t.string :description
      t.integer :account_id
      t.integer :value

      t.timestamps
    end
  end
end
