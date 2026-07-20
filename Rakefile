begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

task :debit_credit_migration_paths do
  ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
  ActiveRecord::Base.connection_pool.disconnect!
  ActiveRecord::Base.establish_connection(Rails.env.to_sym)
end

# Rails 8's engine task adds engine migrations to DatabaseTasks, while the
# migration connection reads ActiveRecord::Migrator.migrations_paths. Make
# that path sync run immediately before repository migration operations.
%w[migrate migrate:status].each do |operation|
  Rake::Task["app:db:#{operation}"].enhance ["debit_credit_migration_paths"]
end

# The Rails 8 engine wrapper can finish app:db:migrate without running the
# combined context when invoked alongside db:drop and db:create. Re-run the
# idempotent migration operation and dump the resulting schema.
Rake::Task["app:db:migrate"].enhance do
  ActiveRecord::Tasks::DatabaseTasks.migrate_all
  schema_dump = Rake::Task["app:db:schema:dump"]
  schema_dump.reenable
  schema_dump.invoke
end

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

# Top-level alias so `rake dummy:boot` works as documented in AGENTS.md.
task "dummy:boot" => "app:dummy:boot"

task default: :test

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = %w[--display-cop-names]
  end
rescue LoadError
  # rubocop is a development dependency; optional in minimal environments.
end

task style: :rubocop
