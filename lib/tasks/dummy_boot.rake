namespace :dummy do
  task :boot do
    require_relative "../../test/dummy/config/environment"
    puts "Rails #{Rails::VERSION::STRING}"
    puts "Debitcredit #{Debitcredit::VERSION}"
  end
end
