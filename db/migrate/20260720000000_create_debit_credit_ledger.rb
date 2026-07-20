class CreateDebitCreditLedger < ActiveRecord::Migration[8.0]
  def change
    create_table :debit_credit_accounts do |t|
      t.string  :name, null: false, limit: 32
      t.string  :type, null: false, limit: 32
      t.references :reference, polymorphic: true, null: true, index: false
      t.decimal :balance, null: false, precision: 20, scale: 2, default: 0
      t.boolean :overdraft_enabled, null: false, default: false
      t.timestamps
    end

    create_table :debit_credit_entries do |t|
      t.references :reference, polymorphic: true, null: true, index: false
      t.string :kind, null: true
      t.string :description, null: false
      t.references :parent_entry, null: true, foreign_key: false, index: false
      t.references :inverse_entry, null: true, foreign_key: false, index: false
      t.timestamps
    end

    create_table :debit_credit_items do |t|
      t.references :entry, null: false, foreign_key: false, index: false
      t.references :account, null: false, foreign_key: false, index: false
      t.boolean :debit, null: false
      t.string :comment, null: true
      t.decimal :amount, null: false, precision: 20, scale: 2, default: 0
      t.decimal :balance, null: false, precision: 20, scale: 2, default: 0
      t.timestamps
    end

    add_index :debit_credit_accounts, [:name, :reference_id, :reference_type],
              unique: true, name: :index_debit_credit_accounts_on_name_and_reference
    add_index :debit_credit_entries, [:parent_entry_id], name: :index_debit_credit_entries_on_parent_entry_id
    add_index :debit_credit_entries, [:reference_id, :reference_type, :id],
              name: :index_debit_credit_entries_on_reference
    add_index :debit_credit_items, [:account_id], name: :index_debit_credit_items_on_account_id
    add_index :debit_credit_items, [:entry_id], name: :index_debit_credit_items_on_entry_id
  end
end
