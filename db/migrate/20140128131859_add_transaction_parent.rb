class AddTransactionParent < ActiveRecord::Migration[8.0]
  def change
    add_column :debit_credit_transactions, :parent_transaction_id, :integer
    add_index :debit_credit_transactions, [:parent_transaction_id]
  end
end
