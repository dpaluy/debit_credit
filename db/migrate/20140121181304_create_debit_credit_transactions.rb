class CreateDebitCreditTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :debit_credit_transactions do |t|
      t.integer :reference_id,   null: true
      t.string  :reference_type, null: true, limit: 32
      t.string  :kind,           null: true
      t.string  :description,    null: false

      t.timestamps
    end
    add_index :debit_credit_transactions, [:reference_id, :reference_type, :id], name: :index_debit_credit_transactions_on_reference
  end
end
