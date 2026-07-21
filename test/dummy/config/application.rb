require_relative "boot"

require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)
require "debit_credit"

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
  end
end
