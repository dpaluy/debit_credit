ENV["RAILS_ENV"] ||= "test"

require File.expand_path("dummy/config/environment", __dir__)

# Engine root migrations live in db/migrate; the dummy host migration lives in
# test/dummy/db/migrate. Both must be on the migration path so the full schema
# (users + debit_credit_*) is available to the test database. Must be set before
# rails/test_help runs maintain_test_schema!.
engine_root = File.expand_path("..", __dir__)
ActiveRecord::Migrator.migrations_paths = [
  File.join(engine_root, "db/migrate"),
  File.expand_path("db/migrate", Rails.root)
]

require "rails/test_help"

ActiveRecord::Migration.maintain_test_schema!

ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
ActiveSupport::TestCase.fixtures :all

require "support/record_helpers"
require "support/valid_fixtures"

ActiveSupport::TestCase.include RecordHelpers
