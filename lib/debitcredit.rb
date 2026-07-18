require "debitcredit/version"
require "active_support"
require "active_support/core_ext/module/delegation"
require "action_dispatch"
require "active_record"
require "rails/engine"
require "debitcredit/engine"

models_path = File.expand_path("../app/models/debitcredit", __dir__)
%w[
  application_record
  account
  debit_account
  credit_account
  asset_account
  liability_account
  income_account
  expense_account
  equity_account
  item
  entry
  entry/dsl
  extension
].each do |model|
  require File.join(models_path, model)
end

module Debitcredit
end
