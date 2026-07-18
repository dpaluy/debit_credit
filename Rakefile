begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)

load "rails/tasks/engine.rake"
task "debitcredit:install:migrations" => "app:debitcredit:install:migrations"

Rake::Task["app:db:load_config"].enhance do
  engine_migrations = File.expand_path("db/migrate", __dir__)
  paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths.reject do |path|
    File.expand_path(path) == engine_migrations
  end
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = paths
  ActiveRecord::Migrator.migrations_paths = paths
end

load File.expand_path("lib/tasks/dummy_boot.rake", __dir__)

require "rake/testtask"
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

task default: :test

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop)
task style: :rubocop

require "bundler/gem_tasks"
