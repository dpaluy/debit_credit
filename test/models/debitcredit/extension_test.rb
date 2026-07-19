require "test_helper"

module Debitcredit
  class ExtensionTest < ActiveSupport::TestCase
    test "has_accounts defines methods that create accounts" do
      acc = users(:john).accounts.cash

      assert_instance_of Debitcredit::AssetAccount, acc
      assert_equal users(:john).accounts[:cash], acc
    end

    test "has_accounts allows defining methods" do
      assert_equal :ok, users(:john).accounts.accounts_method
    end

    test "has_entries defines []" do
      assert_equal debitcredit_entries(:laptop_purchase), users(:john).entries[:purchase]
    end

    test "has_entries allows defining methods" do
      assert_equal :ok, users(:john).entries.entries_method
    end
  end
end
