require "test_helper"

module Debitcredit
  class ExtensionTest < ActiveSupport::TestCase
    def setup
      @john = users(:john)
      @laptop_purchase = debitcredit_entries(:laptop_purchase)
    end

    test "has_accounts defines methods that create accounts" do
      account = @john.accounts.cash
      assert_equal AssetAccount, account.class
      assert_equal account, @john.accounts[:cash]
    end

    test "has_accounts allows defining methods" do
      assert_equal :ok, @john.accounts.accounts_method
    end

    test "has_entries defines []" do
      assert_equal @laptop_purchase, @john.entries[:purchase]
    end

    test "has_entries allows defining methods" do
      assert_equal :ok, @john.entries.entries_method
    end
  end
end
