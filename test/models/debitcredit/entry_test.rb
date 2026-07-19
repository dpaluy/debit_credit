require "test_helper"

module Debitcredit
  class EntryTest < ActiveSupport::TestCase
    def valid_attrs
      { description: "something", reference: users(:john) }
    end

    def equipment = debitcredit_accounts(:equipment)
    def bank = debitcredit_accounts(:bank)
    def amex = debitcredit_accounts(:amex)
    def rent = debitcredit_accounts(:rent)
    def capital = debitcredit_accounts(:capital)

    def entry
      debitcredit_entries(:laptop_purchase)
    end

    def prepare(opts = {}, &)
      @r = Debitcredit::Entry.prepare(valid_attrs.merge(opts), &)
    end

    # ---- validations ----

    test "fixtures are valid" do
      assert_valid_fixtures(Debitcredit::Entry)
    end

    test "sets kind" do
      t = prepare { kind "foo" }

      assert_equal "foo", t.kind
    end

    test "sets description" do
      t = prepare { description "bar" }

      assert_equal "bar", t.description
    end

    test "sets alias description" do
      t = prepare { desc "baz" }

      assert_equal "baz", t.description
    end

    test "sets reference" do
      t = prepare { reference users(:bill) }

      assert_equal users(:bill), t.reference
    end

    test "aliases reference" do
      t = prepare { ref users(:bill) }

      assert_equal users(:bill), t.reference
    end

    test "is valid with balanced items" do
      t = prepare do
        credit bank, 100
        credit amex, 1_000
        debit  rent, 1_100
      end

      assert_predicate t, :balanced?
      assert_predicate t, :valid?
    end

    test "is not valid with unbalanced items" do
      t = prepare do
        credit amex, 1_000
        debit rent, 999
      end

      assert_not t.balanced?
      assert_not t.valid?
    end

    test "locks and updates account balances after validation" do
      amex2 = Debitcredit::Account[:amex]

      assert_equal 10_000, equipment.balance
      assert_equal 100_000, bank.balance
      assert_equal 10_000, amex.balance
      assert_equal 10_000, amex2.balance

      t = prepare do
        debit  equipment, 1_100
        credit bank,      1_000
        credit amex,      50
        credit amex2,     50
      end

      assert_predicate t, :valid?
      t.save!

      assert_equal 11_100, equipment.reload.balance
      assert_equal 99_000, bank.reload.balance
      assert_equal 10_050, amex.balance
      assert_equal 10_100, amex.reload.balance
      assert_equal 10_100, amex2.reload.balance
    end

    test "fails to overdraft" do
      t = prepare do
        credit bank, 100_000.1
        debit equipment, 100_000.1
      end
      assert_raises(ActiveRecord::RecordInvalid) { t.save! }
    end

    # ---- .prepare ----

    test ".prepare allows using symbols for accounts" do
      t = users(:john).entries.prepare do
        debit :equipment, 100
        credit :bank, 100
      end

      assert_equal [equipment, bank], t.items.map(&:account)
    end

    # ---- .inverse ----

    test ".inverse is valid" do
      inverse = entry.inverse

      assert_predicate inverse, :valid?
    end

    test ".inverse takes description and kind" do
      inverse = entry.inverse(description: "foo", kind: "rollback")

      assert_equal "foo", inverse.description
      assert_equal "rollback", inverse.kind
    end

    test ".inverse has default description" do
      inverse = entry.inverse(kind: "rollback")

      assert_equal "reverse of tr ##{entry.id}: apple MBPr", inverse.description
    end

    test ".inverse has default kind" do
      inverse = entry.inverse

      assert_equal "rollback", inverse.kind
    end

    test ".inverse has default reference" do
      inverse = entry.inverse

      assert_equal entry.reference, inverse.reference
    end

    test ".inverse sets default parent_entry_id" do
      inverse = entry.inverse

      assert_equal entry, inverse.parent_entry
    end

    test ".inverse sets inverse_entry_id on parent" do
      inverse = entry.inverse
      inverse.save!

      assert_equal inverse, entry.reload.inverse_entry
    end

    test ".inverse does not allow inversing inversed entries" do
      entry.inverse.save!

      assert_not entry.inverse.valid?
    end

    test ".inverse has inverted items" do
      assert_equal [amex, equipment], entry.items.sort_by(&:kind).map(&:account)
      assert_equal [equipment, amex], entry.inverse.items.sort_by(&:kind).map(&:account)
    end

    test ".inverse sets ignore_overdraft to true" do
      assert_nil entry.ignore_overdraft
      assert entry.inverse.ignore_overdraft
    end
  end
end
