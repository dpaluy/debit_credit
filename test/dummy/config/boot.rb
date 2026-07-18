ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)
ENV.delete("DATABASE_URL") if ENV.fetch("DB", "sqlite") == "sqlite"

require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
