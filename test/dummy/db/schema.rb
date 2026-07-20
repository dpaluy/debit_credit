# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2015_01_06_165647) do
  create_table "debit_credit_accounts", force: :cascade do |t|
    t.decimal "balance", precision: 20, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil
    t.string "name", limit: 32, null: false
    t.boolean "overdraft_enabled", default: false, null: false
    t.integer "reference_id"
    t.string "reference_type", limit: 32
    t.string "type", limit: 32, null: false
    t.datetime "updated_at", precision: nil
    t.index ["name", "reference_id", "reference_type"], name: "index_debit_credit_accounts_on_name_and_reference", unique: true
  end

  create_table "debit_credit_entries", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "description", null: false
    t.integer "inverse_entry_id"
    t.string "kind"
    t.integer "parent_entry_id"
    t.integer "reference_id"
    t.string "reference_type", limit: 32
    t.datetime "updated_at", precision: nil
    t.index ["parent_entry_id"], name: "index_debit_credit_entries_on_parent_entry_id"
    t.index ["reference_id", "reference_type", "id"], name: "index_debit_credit_entries_on_reference"
  end

  create_table "debit_credit_items", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount", precision: 20, scale: 2, default: "0.0", null: false
    t.decimal "balance", precision: 20, scale: 2, default: "0.0", null: false
    t.string "comment"
    t.datetime "created_at", precision: nil
    t.boolean "debit", null: false
    t.integer "entry_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["account_id"], name: "index_debit_credit_items_on_account_id"
    t.index ["entry_id"], name: "index_debit_credit_items_on_entry_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end
end
