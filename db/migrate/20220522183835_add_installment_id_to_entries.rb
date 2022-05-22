class AddInstallmentIdToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :installment_id, :integer
  end
end
