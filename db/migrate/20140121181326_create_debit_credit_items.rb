class CreateDebitCreditItems < ActiveRecord::Migration[8.0]
  def change
    create_table :debit_credit_items do |t|
      t.references :transaction, null: false
      t.references :account,     null: false
      t.boolean    :debit,       null: false
      t.string     :comment,     null: true
      t.decimal    :amount,      null: false, precision: 20, scale: 2, default: 0
      t.decimal    :balance,     null: false, precision: 20, scale: 2, default: 0
      t.timestamps
    end
    add_index :debit_credit_items, :account_id
    add_index :debit_credit_items, :transaction_id
  end
end
