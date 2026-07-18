require "test_helper"

module Debitcredit
  class AccountTest < ActiveSupport::TestCase
    include RecordHelpers
    include ValidFixtures

    def setup
      @john = users(:john)
      @equipment = debitcredit_accounts(:equipment)
      @rent = debitcredit_accounts(:rent)
      @bank = debitcredit_accounts(:bank)
      @salary = debitcredit_accounts(:salary)
      @amex = debitcredit_accounts(:amex)
      @capital = debitcredit_accounts(:capital)
    end

    def described_class
      Debitcredit::AssetAccount
    end

    def valid_attrs
      { name: "foo" }
    end

    test ".by_kind finds account class by kind" do
      assert_equal Debitcredit::AssetAccount, Account.by_kind(:asset)
    end

    test "all account fixtures are valid" do
      assert_valid_fixtures(Account)
    end

    test "overdraft disabled prevents negative balance" do
      record(overdraft_enabled: false).save!
      record.check_overdraft = true
      record.balance = -1
      assert_not record.valid?
      assert record.errors[:balance].any?
    end

    test "overdraft disabled ignores overdraft when check_overdraft is false" do
      record(overdraft_enabled: false).save!
      record.balance = -1
      assert_predicate record, :valid?
    end

    test "overdraft disabled allows keeping a negative balance" do
      record(overdraft_enabled: false, balance: -10).save
      record.check_overdraft = true
      assert_predicate record, :valid?
    end

    test "overdraft disabled allows increasing a negative balance" do
      record(overdraft_enabled: false, balance: -10).save
      record.check_overdraft = true
      record.balance = -5
      assert_predicate record, :valid?
    end

    test "overdraft disabled allows decreasing a positive balance" do
      record(overdraft_enabled: false, balance: 10).save
      record.check_overdraft = true
      record.balance = 5
      assert_predicate record, :valid?
    end

    test "overdraft enabled allows a negative balance" do
      record(overdraft_enabled: true).save!
      record.balance = -1
      assert_predicate record, :valid?
      assert_empty record.errors[:balance]
    end

    test "finds an account by name" do
      assert_equal @amex, Account[:amex]
    end

    test "finds an account by name and kind" do
      assert_equal @amex, Account[:amex, :liability]
    end

    test "creates an account when kind is provided and none exists" do
      assert_difference -> { Account.count }, 1 do
        foo = Account[:foo, :expense]
        assert_equal Debitcredit::ExpenseAccount, foo.class
        assert_equal "foo", foo.name
        assert_equal 0, foo.balance
      end
    end

    test "raises when no account exists and kind is not provided" do
      error = assert_raises(Account::NotFound) { Account[:foo] }
      assert_match(/not found/, error.message)
    end

    test "updates overdraft when it differs" do
      assert_not @rent.overdraft_enabled?
      Account[:rent, :expense, true]
      assert @rent.reload.overdraft_enabled?
    end

    test "raises on a different kind" do
      assert_raises(Account::BadKind) { Account[:rent, :asset] }
    end

    test "creates an account with a reference" do
      foo = @john.accounts[:foo, :asset]
      assert_equal @john, foo.reference
      assert_equal Debitcredit::AssetAccount, foo.class
      assert_equal "foo", foo.name
    end

    test "is initially balanced" do
      assert_predicate Account, :balanced?
    end

    test "is unbalanced after a balance change" do
      @equipment.balance += 1
      @equipment.save!
      assert_not Account.balanced?
    end

    test "supports the A + Ex = L + E + I accounting equation" do
      @equipment.balance += 5
      @equipment.save!
      @rent.balance += 9
      @rent.save!
      @amex.balance += 2
      @amex.save!
      @capital.balance += 4
      @capital.save!
      @salary.balance += 8
      @salary.save!

      assert_predicate Account, :balanced?
    end
  end
end
