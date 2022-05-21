class AddTypeIdToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :type_id, :integer
  end
end
