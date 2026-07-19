require "test_helper"

module Debitcredit
  class ItemTest < ActiveSupport::TestCase
    test "fixtures are valid" do
      assert_valid_fixtures(Debitcredit::Item, count: 2)
    end

    def described_class
      Debitcredit::Item
    end

    def valid_attrs
      {
        entry: debitcredit_entries(:laptop_purchase),
        account: debitcredit_accounts(:equipment),
        debit: true,
        amount: 10
      }
    end

    test ".inverse does not change record" do
      r = record
      r.save!
      r.inverse
      assert_not r.changed?
    end

    test ".inverse retains account" do
      assert_equal record.account, record.inverse.account
    end

    test ".inverse retains entry" do
      assert_equal record.entry, record.inverse.entry
    end

    test ".inverse retains amount" do
      assert_equal record.amount, record.inverse.amount
    end

    test ".inverse inverts kind" do
      assert _record(debit: true).inverse.credit?
      assert _record(debit: false).inverse.debit?
    end
  end
end
