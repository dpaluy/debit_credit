# frozen_string_literal: true

namespace :dummy do
  desc "Boot the Rails 8 dummy app and report Rails + Debitcredit versions"
  task boot: :environment do
    puts "Rails #{Rails::VERSION::STRING}"
    puts "Debitcredit #{Debitcredit::VERSION}"
    puts "Adapter: #{ActiveRecord::Base.connection.adapter_name}"
  end
end
