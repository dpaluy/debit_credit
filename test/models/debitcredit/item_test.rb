require "test_helper"

module Debitcredit
  class ItemTest < ActiveSupport::TestCase
    include RecordHelpers
    include ValidFixtures

    def setup
      @laptop_purchase = debitcredit_entries(:laptop_purchase)
      @equipment = debitcredit_accounts(:equipment)
    end

    def described_class
      Debitcredit::Item
    end

    def valid_attrs
      { entry: @laptop_purchase, account: @equipment, debit: true, amount: 10 }
    end

    test "all item fixtures are valid" do
      assert_valid_fixtures(Item)
    end

    test "inverse does not change the source record" do
      record.save!
      record.inverse
      assert_not record.changed?
    end

    test "inverse retains the account" do
      assert_equal record.account, record.inverse.account
    end

    test "inverse retains the entry" do
      assert_equal record.entry, record.inverse.entry
    end

    test "inverse retains the amount" do
      assert_equal record.amount, record.inverse.amount
    end

    test "inverse changes debit to credit" do
      assert_predicate _record(debit: true).inverse, :credit?
      assert_predicate _record(debit: false).inverse, :debit?
    end
  end
end
