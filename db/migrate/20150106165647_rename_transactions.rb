class RenameTransactions < ActiveRecord::Migration[4.2]
  def change
    rename_table :debit_credit_transactions, :debit_credit_entries
    rename_index :debit_credit_entries, "index_debit_credit_transactions_on_reference", "index_debit_credit_entries_on_reference"
    rename_column :debit_credit_entries, :parent_transaction_id, :parent_entry_id
    rename_column :debit_credit_entries, :inverse_transaction_id, :inverse_entry_id

    rename_column :debit_credit_items, :transaction_id, :entry_id
  end
end
