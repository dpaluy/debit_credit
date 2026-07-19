begin
  require "bundler/setup"
rescue LoadError
  warn "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "bundler/gem_tasks"
require "rake/testtask"

# Top-level alias so `rake dummy:boot` works as documented in AGENTS.md/SKILL.md.
task "dummy:boot" => "app:dummy:boot"
