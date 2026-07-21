module DebitCredit
  class Engine < ::Rails::Engine
    isolate_namespace DebitCredit
    config.generators do |g|
      g.api_only = true
      g.test_framework :minitest
    end
  end
end
