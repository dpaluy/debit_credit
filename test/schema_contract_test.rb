require "test_helper"

# Schema contract: verifies the migrated database matches the final
# debit_credit-ledger 1.0.0 schema. Inspects only the live catalog through
# Active Record; never reads repository files or shells out to Git.
#
# The key distinction this contract enforces is PostgreSQL reference width:
# `col.type` reports `:integer` for both 4-byte integer and 8-byte bigint,
# so the test inspects `sql_type` to distinguish them. On PostgreSQL every
# relationship column must be `bigint`; on SQLite integer affinity is correct
# because SQLite has no distinct bigint storage class.
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

    assert_primary_key cols["id"]
    assert_equal :string, cols["name"].type
    refute cols["name"].null
    assert_equal 32,      cols["name"].limit
    assert_equal :string, cols["type"].type
    refute cols["type"].null
    assert_equal 32, cols["type"].limit
    assert_reference cols["reference_id"]
    assert_polymorphic_type cols["reference_type"]
    assert_nil             cols["reference_id"].default
    assert_nil             cols["reference_type"].default
    assert cols["reference_id"].null
    assert cols["reference_type"].null
    assert_equal :decimal, cols["balance"].type
    assert_equal 20,       cols["balance"].precision
    assert_equal 2,        cols["balance"].scale
    refute cols["balance"].null
    assert_equal :boolean, cols["overdraft_enabled"].type
    refute cols["overdraft_enabled"].null
    refute cols["overdraft_enabled"].default
  end

  test "entries table columns and types" do
    cols = columns(ENTRIES)

    assert_primary_key cols["id"]
    assert_reference cols["reference_id"]
    assert_polymorphic_type cols["reference_type"]
    assert_nil             cols["reference_id"].default
    assert_nil             cols["reference_type"].default
    assert cols["reference_id"].null
    assert cols["reference_type"].null
    assert_equal :string,  cols["kind"].type
    assert_nil             cols["kind"].default
    assert cols["kind"].null
    assert_equal :string, cols["description"].type
    refute cols["description"].null
    assert_nil cols["description"].default
    assert_reference cols["parent_entry_id"]
    assert_nil cols["parent_entry_id"].default
    assert cols["parent_entry_id"].null
    assert_reference cols["inverse_entry_id"]
    assert_nil cols["inverse_entry_id"].default
    assert cols["inverse_entry_id"].null
  end

  test "items table columns and types" do
    cols = columns(ITEMS)

    assert_primary_key cols["id"]
    assert_reference cols["entry_id"]
    refute cols["entry_id"].null
    assert_nil cols["entry_id"].default
    assert_reference cols["account_id"]
    refute cols["account_id"].null
    assert_nil cols["account_id"].default
    assert_equal :boolean, cols["debit"].type
    refute cols["debit"].null
    assert_nil             cols["debit"].default
    assert_equal :string,  cols["comment"].type
    assert_nil             cols["comment"].default
    assert cols["comment"].null
    assert_equal :decimal, cols["amount"].type
    assert_equal 20,       cols["amount"].precision
    assert_equal 2,        cols["amount"].scale
    refute cols["amount"].null
    assert_equal :decimal, cols["balance"].type
    assert_equal 20,       cols["balance"].precision
    assert_equal 2,        cols["balance"].scale
    refute cols["balance"].null
  end

  test "decimal columns default to zero" do
    assert_equal 0, columns(ACCOUNTS)["balance"].default.to_d
    assert_equal 0, columns(ITEMS)["amount"].default.to_d
    assert_equal 0, columns(ITEMS)["balance"].default.to_d
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

  test "primary key is bigint on PostgreSQL, integer on SQLite" do
    [ACCOUNTS, ENTRIES, ITEMS].each do |table|
      assert_primary_key columns(table)["id"]
    end
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

  # Primary keys are adapter-native: bigint on PostgreSQL, integer on SQLite.
  # We check sql_type so a 4-byte PostgreSQL integer would fail here.
  def assert_primary_key(col)
    assert_equal :integer, col.type
    assert_nil col.default
    refute col.null
    return unless postgresql?

    assert_equal "bigint", col.sql_type,
                 "expected bigint primary key on PostgreSQL, got #{col.sql_type}"
  end

  # Every relationship column must be bigint on PostgreSQL. The logical
  # `:integer` type alone cannot prove this because both integer and bigint
  # report `:integer`; the sql_type must be `bigint` (8-byte) on PostgreSQL.
  def assert_reference(col)
    assert_equal :integer, col.type
    return unless postgresql?

    assert_equal "bigint", col.sql_type,
                 "expected bigint reference on PostgreSQL, got #{col.sql_type}"
  end

  # Polymorphic _type columns must be string with limit 32 on both adapters.
  def assert_polymorphic_type(col)
    assert_equal :string, col.type
    assert_equal 32, col.limit,
                 "expected polymorphic type limit 32, got #{col.limit.inspect}"
  end
end
