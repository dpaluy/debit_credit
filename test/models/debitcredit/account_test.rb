require "test_helper"

module Debitcredit
  class AccountTest < ActiveSupport::TestCase
    # Fixtures: users(:john), users(:bill), debitcredit_accounts(:name).
    def equipment; debitcredit_accounts(:equipment); end
    def rent;      debitcredit_accounts(:rent);      end
    def bank;      debitcredit_accounts(:bank);      end
    def amex;      debitcredit_accounts(:amex);      end
    def capital;   debitcredit_accounts(:capital);   end
    def salary;    debitcredit_accounts(:salary);    end

    test ".by_kind finds account class by kind" do
      assert_equal Debitcredit::AssetAccount, Debitcredit::Account.by_kind(:asset)
    end

    test "fixtures are valid" do
      assert_valid_fixtures(Debitcredit::Account, count: 6)
    end

    test "[] finds account by name" do
      assert_equal amex, Debitcredit::Account[:amex]
    end

    test "[] finds account by name and kind" do
      assert_equal amex, Debitcredit::Account[:amex, :liability]
    end

    test "[] creates account if kind is provided and none exists" do
      assert_difference -> { Debitcredit::Account.count }, 1 do
        foo = Debitcredit::Account[:foo, :expense]
        assert_equal Debitcredit::ExpenseAccount, foo.class
        assert_equal "foo", foo.name
        assert_equal 0, foo.balance
      end
    end

    test "[] raises NotFound if none exists and no kind provided" do
      err = assert_raises(Debitcredit::Account::NotFound) { Debitcredit::Account[:foo] }
      assert_match(/not found/, err.message)
    end

    test "[] updates overdraft if different" do
      assert_not rent.overdraft_enabled?
      Debitcredit::Account[:rent, :expense, true]
      assert rent.reload.overdraft_enabled?
    end

    test "[] raises BadKind on different kind" do
      assert_raises(Debitcredit::Account::BadKind) do
        Debitcredit::Account[:rent, :asset]
      end
    end

    test "[] creates with reference via association" do
      foo = users(:john).accounts[:foo, :asset]
      assert_equal users(:john), foo.reference
      assert_equal Debitcredit::AssetAccount, foo.class
      assert_equal "foo", foo.name
    end

    test ".balanced? is initially true" do
      assert Debitcredit::Account.balanced?
    end

    test ".balanced? is false if out of balance" do
      equipment.balance += 1
      equipment.save!
      assert_not Debitcredit::Account.balanced?
    end

    test ".balanced? A + Ex = L + E + I" do
      equipment.balance += 5
      equipment.save!

      rent.balance += 9
      rent.save!

      amex.balance += 2
      amex.save!

      capital.balance += 4
      capital.save!

      salary.balance += 8
      salary.save!

      assert Debitcredit::Account.balanced?
    end
  end

  # Overdraft-disabled behavior.
  class AccountOverdraftDisabledTest < ActiveSupport::TestCase
    def described_class
      Debitcredit::AssetAccount
    end

    def valid_attrs
      { name: "foo" }
    end

    def extra_attrs
      { overdraft_enabled: false }
    end

    test "prevents negative balance" do
      r = record
      r.save!
      r.check_overdraft = true
      r.balance = -1
      assert_not r.valid?
      assert_not r.errors[:balance].blank?
    end

    test "ignores overdraft when check_overdraft is false" do
      r = record
      r.save!
      r.balance = -1
      assert r.valid?
    end

    test "allows keeping negative balance" do
      r = _record(balance: -10)
      r.save
      r.check_overdraft = true
      assert r.valid?
    end

    test "allows + on negative balance" do
      r = _record(balance: -10)
      r.save
      r.check_overdraft = true
      r.balance = -5
      assert r.valid?
    end

    test "allows - on positive balance" do
      r = _record(balance: 10)
      r.save
      r.check_overdraft = true
      r.balance = 5
      assert r.valid?
    end
  end

  # Overdraft-enabled behavior.
  class AccountOverdraftEnabledTest < ActiveSupport::TestCase
    def described_class
      Debitcredit::AssetAccount
    end

    def valid_attrs
      { name: "foo" }
    end

    def extra_attrs
      { overdraft_enabled: true }
    end

    test "allows negative balance when overdraft_enabled? is true" do
      r = record
      r.save!
      r.balance = -1
      assert r.valid?
      assert r.errors[:balance].blank?
    end
  end
end
