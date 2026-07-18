ENV["RAILS_ENV"] ||= "test"

require_relative "dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__)]
ActiveRecord::Migration.maintain_test_schema!

require "rails/test_help"

ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
ActiveSupport::TestCase.fixtures :all

require_relative "support/record_helpers"
require_relative "support/valid_fixtures"
