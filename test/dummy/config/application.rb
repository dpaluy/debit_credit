require_relative "boot"

require "active_record/railtie"

Bundler.require(*Rails.groups)
require "debitcredit"

module TestDummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
  end
end
