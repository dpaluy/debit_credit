# This migration comes from debitcredit (originally 20140128131859)
class AddTransactionParent < ActiveRecord::Migration[4.2]
  def change
    add_column :debitcredit_transactions, :parent_transaction_id, :integer
    add_index :debitcredit_transactions, [:parent_transaction_id]
  end
end
