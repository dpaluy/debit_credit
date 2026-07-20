class CreateDebitCreditAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :debit_credit_accounts do |t|
      t.string  :name,           null: false, limit:     16
      t.string  :type,           null: false, limit:     32
      t.integer :reference_id,   null: true
      t.string  :reference_type, null: true,  limit:     32
      t.decimal :balance,        null: false, precision: 20, scale: 2, default: 0

      t.timestamps
    end
    add_index :debit_credit_accounts, [:name, :reference_id, :reference_type], unique: true, name: :index_debit_credit_accounts_on_name_and_reference
  end
end
