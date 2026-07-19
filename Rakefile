begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

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
