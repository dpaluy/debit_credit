module RecordHelpers
  def record_class
    described_class
  end

  def _record(attrs = {})
    attributes = valid_attrs
    attributes = attributes.merge(extra_attrs) if respond_to?(:extra_attrs)
    record_class.new(attributes.merge(attrs))
  end

  def record(attrs = {})
    @_record ||= _record(attrs)
  end
end
