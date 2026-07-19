module RecordHelpers
  # Default class under test. Override `described_class` in each test case.
  def described_class
    Debitcredit::AssetAccount
  end

  # Default valid attributes for building records. Override per test case.
  def valid_attrs
    { name: "foo" }
  end

  # Build a fresh record with the given overrides merged onto valid_attrs
  # (and extra_attrs if defined). Always returns a NEW instance (no memoization),
  # mirroring the original RSpec `record(attrs)` memoizing helper semantics for
  # the first call while allowing explicit fresh builds via `_record`.
  def record(attrs = {})
    @_record ||= _record(attrs)
  end

  def _record(overrides = {})
    merged = valid_attrs
    merged = merged.merge(extra_attrs) if respond_to?(:extra_attrs)
    described_class.new(merged.merge(overrides))
  end
end
