module ValidFixtures
  def assert_valid_fixtures(record_class, count: nil)
    assert_equal count, record_class.count if count

    record_class.find_each do |fixture_record|
      assert_predicate fixture_record, :valid?, "#{record_class} fixture #{fixture_record.id} is invalid: #{fixture_record.errors.full_messages.join(", ")}"
    end
  end
end
