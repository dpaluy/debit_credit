class AddInverseTransactionId < ActiveRecord::Migration[4.2]
  def change
    add_column :debit_credit_transactions, :inverse_transaction_id, :integer
  end
end
