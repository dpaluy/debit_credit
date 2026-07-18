require "test_helper"

module Debitcredit
  class EntryTest < ActiveSupport::TestCase
    include RecordHelpers
    include ValidFixtures

    def setup
      @john = users(:john)
      @bill = users(:bill)
      @equipment = debitcredit_accounts(:equipment)
      @rent = debitcredit_accounts(:rent)
      @bank = debitcredit_accounts(:bank)
      @amex = debitcredit_accounts(:amex)
      @laptop_purchase = debitcredit_entries(:laptop_purchase)
    end

    def described_class
      Debitcredit::Entry
    end

    def valid_attrs
      { description: "something", reference: @john }
    end

    def entry
      @laptop_purchase
    end

    def prepare(opts = {}, &block)
      Debitcredit::Entry.prepare(valid_attrs.merge(opts), &block)
    end

    test "all entry fixtures are valid" do
      assert_valid_fixtures(Entry)
    end

    test "sets kind through the DSL" do
      prepared = prepare { kind "foo" }
      assert_equal "foo", prepared.kind
    end

    test "sets description through the DSL" do
      prepared = prepare { description "bar" }
      assert_equal "bar", prepared.description
    end

    test "sets description through the desc alias" do
      prepared = prepare { desc "baz" }
      assert_equal "baz", prepared.description
    end

    test "sets reference through the DSL" do
      prepared = prepare { reference @bill }
      assert_equal @bill, prepared.reference
    end

    test "sets reference through the ref alias" do
      prepared = prepare { ref @bill }
      assert_equal @bill, prepared.reference
    end

    test "is valid with balanced items" do
      prepared = prepare do
        credit @bank, 100
        credit @amex, 1_000
        debit @rent, 1_100
      end
      assert_predicate prepared, :balanced?
      assert_predicate prepared, :valid?
    end

    test "is invalid with unbalanced items" do
      prepared = prepare do
        credit @amex, 1_000
        debit @rent, 999
      end
      assert_not prepared.balanced?
      assert_not prepared.valid?
    end

    test "locks and updates account balances after validation" do
      amex2 = Account[:amex]

      assert_equal 10_000, @equipment.balance
      assert_equal 100_000, @bank.balance
      assert_equal 10_000, @amex.balance
      assert_equal 10_000, amex2.balance

      prepared = prepare do
        debit @equipment, 1_100
        credit @bank, 1_000
        credit @amex, 50
        credit amex2, 50
      end

      assert_predicate prepared, :valid?
      prepared.save!

      assert_equal 11_100, @equipment.reload.balance
      assert_equal 99_000, @bank.reload.balance
      assert_equal 10_050, @amex.balance
      assert_equal 10_100, @amex.reload.balance
      assert_equal 10_100, amex2.reload.balance
    end

    test "fails when an entry would overdraft" do
      prepared = prepare do
        credit @bank, 100_000.1
        debit @equipment, 100_000.1
      end

      assert_raises(ActiveRecord::RecordInvalid) { prepared.save! }
    end

    test "allows symbols for accounts" do
      prepared = @john.entries.prepare do
        debit :equipment, 100
        credit :bank, 100
      end
      assert_equal [@equipment, @bank], prepared.items.map(&:account)
    end

    test "an inverse entry is valid" do
      assert_predicate entry.inverse, :valid?
    end

    test "an inverse takes an explicit description and kind" do
      inverse = entry.inverse(description: "foo", kind: "rollback")
      assert_equal "foo", inverse.description
      assert_equal "rollback", inverse.kind
    end

    test "an inverse has a default description" do
      inverse = entry.inverse(kind: "rollback")
      assert_equal "reverse of tr ##{entry.id}: apple MBPr", inverse.description
    end

    test "an inverse has a default kind" do
      assert_equal "rollback", entry.inverse.kind
    end

    test "an inverse has the default reference" do
      assert_equal entry.reference, entry.inverse.reference
    end

    test "an inverse has the parent entry" do
      assert_equal entry, entry.inverse.parent_entry
    end

    test "saving an inverse sets inverse_entry_id on the parent" do
      inverse = entry.inverse
      inverse.save!
      assert_equal inverse, entry.reload.inverse_entry
    end

    test "does not allow inversing an already inversed entry" do
      entry.inverse.save!
      assert_not entry.inverse.valid?
    end

    test "an inverse has inverted items" do
      assert_equal [@amex, @equipment], entry.items.sort_by(&:kind).map(&:account)
      assert_equal [@equipment, @amex], entry.inverse.items.sort_by(&:kind).map(&:account)
    end

    test "an inverse ignores overdraft" do
      assert_nil entry.ignore_overdraft
      assert_equal true, entry.inverse.ignore_overdraft
    end
  end
end
