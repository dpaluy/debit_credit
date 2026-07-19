module ValidFixtures
  # Assert that all fixtures for the given model are valid, optionally checking
  # the count. Usage: assert_valid_fixtures(Debitcredit::Account)
  #                   assert_valid_fixtures(Debitcredit::Account, count: 6)
  def assert_valid_fixtures(klass, count: nil)
    assert_equal count, klass.count if count

    klass.find_each do |record|
      assert_predicate record, :valid?, "Invalid #{klass}: #{record.errors.full_messages.inspect}"
    end
  end
end

ActiveSupport::TestCase.include ValidFixtures
