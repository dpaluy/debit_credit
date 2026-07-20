class AddAccountOverdraft < ActiveRecord::Migration[8.0]
  def change
    add_column :debit_credit_accounts, :overdraft_enabled, :boolean, null: false, default: true
  end
end
