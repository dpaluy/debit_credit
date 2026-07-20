class AddInverseTransactionId < ActiveRecord::Migration[8.0]
  def change
    add_column :debit_credit_transactions, :inverse_transaction_id, :integer
  end
end
