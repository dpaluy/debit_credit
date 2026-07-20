# frozen_string_literal: true

namespace :dummy do
  desc "Boot the Rails 8 dummy app and report Rails + DebitCredit versions"
  task boot: :environment do
    puts "Rails #{Rails::VERSION::STRING}"
    puts "DebitCredit #{DebitCredit::VERSION}"
    puts "Adapter: #{ActiveRecord::Base.connection.adapter_name}"
  end
end
