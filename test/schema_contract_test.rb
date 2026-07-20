require "test_helper"

# Schema contract: verifies the migrated database matches the final
# debit_credit-ledger 1.0.0 schema. Inspects only the live catalog through
# Active Record; never reads repository files or shells out to Git.
class SchemaContractTest < ActiveSupport::TestCase
  ACCOUNTS = "debit_credit_accounts".freeze
  ENTRIES  = "debit_credit_entries".freeze
  ITEMS    = "debit_credit_items".freeze

  test "final schema has exactly the three ledger tables plus users" do
    tables = connection.tables

    assert_includes tables, ACCOUNTS
    assert_includes tables, ENTRIES
    assert_includes tables, ITEMS
    refute_includes tables, "debit_credit_transactions"
  end

  test "accounts table columns and types" do
    cols = columns(ACCOUNTS)

    assert_id_type cols["id"]
    assert_equal :string, cols["name"].type
    refute cols["name"].null
    assert_equal :string, cols["type"].type
    refute cols["type"].null
    assert_reference_id cols["reference_id"]
    assert_equal :string,  cols["reference_type"].type
    assert_nil             cols["reference_id"].default
    assert_nil             cols["reference_type"].default
    assert_equal :decimal, cols["balance"].type
    assert_equal 20,       cols["balance"].precision
    assert_equal 2,        cols["balance"].scale
    refute cols["balance"].null
    assert_equal :boolean, cols["overdraft_enabled"].type
    refute cols["overdraft_enabled"].null
    refute cols["overdraft_enabled"].default
    # String limits are enforced on PostgreSQL for declared columns; polymorphic
    # reference_type has no explicit limit in Rails by default.
    assert_equal 32, cols["name"].limit if postgresql?
    assert_equal 32, cols["type"].limit if postgresql?
  end

  test "entries table columns and types" do
    cols = columns(ENTRIES)

    assert_id_type cols["id"]
    assert_reference_id cols["reference_id"]
    assert_equal :string,  cols["reference_type"].type
    assert_equal :string,  cols["kind"].type
    assert_nil             cols["kind"].default
    assert_equal :string,  cols["description"].type
    refute cols["description"].null
    assert_equal :integer, cols["parent_entry_id"].type if sqlite?

    assert_nil             cols["parent_entry_id"].default
    assert_equal :integer, cols["inverse_entry_id"].type if sqlite?

    assert_nil             cols["inverse_entry_id"].default
  end

  test "items table columns and types" do
    cols = columns(ITEMS)

    assert_id_type cols["id"]
    assert_equal :integer, cols["entry_id"].type if sqlite?

    refute cols["entry_id"].null
    assert_equal :integer, cols["account_id"].type if sqlite?

    refute cols["account_id"].null
    assert_equal :boolean, cols["debit"].type
    refute cols["debit"].null
    assert_nil             cols["debit"].default
    assert_equal :string,  cols["comment"].type
    assert_nil             cols["comment"].default
    assert_equal :decimal, cols["amount"].type
    assert_equal 20,       cols["amount"].precision
    assert_equal 2,        cols["amount"].scale
    assert_equal :decimal, cols["balance"].type
    assert_equal 20,       cols["balance"].precision
    assert_equal 2,        cols["balance"].scale
  end

  test "timestamps are non-null precision-6" do
    [ACCOUNTS, ENTRIES, ITEMS].each do |table|
      created = columns(table)["created_at"]
      updated = columns(table)["updated_at"]

      assert_equal :datetime, created.type, "#{table}.created_at type"
      assert_equal 6,         created.precision, "#{table}.created_at precision"
      refute created.null, "#{table}.created_at null"
      assert_equal :datetime, updated.type, "#{table}.updated_at type"
      assert_equal 6,         updated.precision, "#{table}.updated_at precision"
      refute updated.null, "#{table}.updated_at null"
    end
  end

  test "exactly five secondary indexes with correct uniqueness" do
    indexes = connection.indexes(ACCOUNTS).to_h { |i| [i.name, i] }

    assert indexes.key?("index_debit_credit_accounts_on_name_and_reference")
    assert indexes["index_debit_credit_accounts_on_name_and_reference"].unique

    e_indexes = connection.indexes(ENTRIES).to_h { |i| [i.name, i] }

    assert e_indexes.key?("index_debit_credit_entries_on_parent_entry_id")
    refute e_indexes["index_debit_credit_entries_on_parent_entry_id"].unique
    assert e_indexes.key?("index_debit_credit_entries_on_reference")
    refute e_indexes["index_debit_credit_entries_on_reference"].unique

    i_indexes = connection.indexes(ITEMS).to_h { |i| [i.name, i] }

    assert i_indexes.key?("index_debit_credit_items_on_account_id")
    refute i_indexes["index_debit_credit_items_on_account_id"].unique
    assert i_indexes.key?("index_debit_credit_items_on_entry_id")
    refute i_indexes["index_debit_credit_items_on_entry_id"].unique

    total = indexes.size + e_indexes.size + i_indexes.size

    assert_equal 5, total, "expected 5 secondary indexes, got #{total}"
  end

  test "no foreign keys on any ledger table" do
    [ACCOUNTS, ENTRIES, ITEMS].each do |table|
      fks = connection.foreign_keys(table)

      assert_empty fks, "#{table} should have no foreign keys, got: #{fks.inspect}"
    end
  end

  test "adapter-native id and reference types" do
    assert_id_type columns(ACCOUNTS)["id"]
    assert_reference_id columns(ITEMS)["entry_id"]
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def columns(table)
    connection.columns(table).to_h { |c| [c.name, c] }
  end

  def sqlite?
    ActiveRecord::Base.connection.adapter_name =~ /sqlite/i
  end

  def postgresql?
    ActiveRecord::Base.connection.adapter_name =~ /postgres/i
  end

  def assert_id_type(col)
    assert_equal :integer, col.type
    return unless postgresql?

    assert_equal "bigint", col.sql_type, "expected bigint id on PostgreSQL, got #{col.sql_type}"
  end

  def assert_reference_id(col)
    assert_equal :integer, col.type
    return unless postgresql?

    assert_equal "bigint", col.sql_type, "expected bigint reference on PostgreSQL, got #{col.sql_type}"
  end
end
