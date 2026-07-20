require "test_helper"

class NamingContractTest < ActiveSupport::TestCase
  CANONICAL_PATHS = %w[
    debit_credit-ledger.gemspec
    lib/debit_credit.rb
    lib/debit_credit/engine.rb
    lib/debit_credit/version.rb
    lib/tasks/debit_credit_tasks.rake
    app/models/debit_credit/account.rb
    app/models/debit_credit/application_record.rb
    app/models/debit_credit/asset_account.rb
    app/models/debit_credit/credit_account.rb
    app/models/debit_credit/debit_account.rb
    app/models/debit_credit/entry.rb
    app/models/debit_credit/entry/dsl.rb
    app/models/debit_credit/equity_account.rb
    app/models/debit_credit/expense_account.rb
    app/models/debit_credit/extension.rb
    app/models/debit_credit/income_account.rb
    app/models/debit_credit/item.rb
    app/models/debit_credit/liability_account.rb
    test/fixtures/debit_credit/accounts.yml
    test/fixtures/debit_credit/entries.yml
    test/fixtures/debit_credit/items.yml
    test/models/debit_credit/account_test.rb
    test/models/debit_credit/entry_test.rb
    test/models/debit_credit/extension_test.rb
    test/models/debit_credit/item_test.rb
    db/migrate/20140121145455_create_debit_credit_accounts.rb
    db/migrate/20140121181304_create_debit_credit_transactions.rb
    db/migrate/20140121181326_create_debit_credit_items.rb
  ].freeze

  def test_tracked_paths_and_contents_use_canonical_identity
    legacy_token = %w[debit credit].join
    canonical_namespace = %w[Debit Credit].join
    tracked_paths = tracked_paths()
    path_hits = tracked_paths.grep(/#{Regexp.escape(legacy_token)}/i)
    content_hits = legacy_content_hits(tracked_paths, legacy_token, canonical_namespace)

    assert_empty path_hits, "legacy paths: #{path_hits.inspect}"
    assert_empty content_hits, "legacy content: #{content_hits.inspect}"
  end

  def test_canonical_runtime_identity_is_public
    legacy_constant = %w[Debit credit].join

    assert defined?(DebitCredit)
    assert_equal "1.0.0", DebitCredit::VERSION
    refute Object.const_defined?(legacy_constant, false)
    assert_equal "debit_credit", DebitCredit::Engine.engine_name
    assert_equal "debit_credit", DebitCredit::Engine.railtie_name
  end

  def test_canonical_paths_and_models_are_present
    tracked_paths = tracked_paths()

    assert_empty CANONICAL_PATHS - tracked_paths
    assert_equal "debit_credit_accounts", DebitCredit::Account.table_name
    assert_equal "debit_credit_entries", DebitCredit::Entry.table_name
    assert_equal "debit_credit_items", DebitCredit::Item.table_name

    locale = File.read(File.join(repository_root, "config/locales/en.yml"))

    assert_includes locale, "debit_credit/entry:"
    assert_includes locale, "debit_credit/account:"
  end

  def test_metadata_and_dummy_app_use_canonical_distribution
    gemspec = File.read(File.join(repository_root, "debit_credit-ledger.gemspec"))
    lockfile = File.read(File.join(repository_root, "Gemfile.lock"))
    dummy_application = File.read(File.join(repository_root, "test/dummy/config/application.rb"))

    assert_includes gemspec, 's.name = "debit_credit-ledger"'
    assert_includes gemspec, "https://github.com/dpaluy/debit_credit"
    assert_includes lockfile, "debit_credit-ledger (1.0.0)"
    assert_includes dummy_application, 'require "debit_credit"'
  end

  private

  def tracked_paths
    Dir.chdir(repository_root) { `git ls-files -z`.split("\0") }
  end

  def legacy_content_hits(paths, token, canonical_namespace)
    paths.flat_map { |path| legacy_content_hits_for(path, token, canonical_namespace) }
  end

  def legacy_content_hits_for(path, token, canonical_namespace)
    file = File.join(repository_root, path)
    return [] unless File.file?(file)

    data = File.binread(file)
    return [] if data.include?("\0")

    data.each_line.with_index(1).filter_map do |line, number|
      legacy_line_hit(path, line, number, token, canonical_namespace)
    end
  end

  def legacy_line_hit(path, line, number, token, canonical_namespace)
    scan_line = line.gsub(canonical_namespace, "")
    return unless scan_line.match?(/#{Regexp.escape(token)}/i)

    "#{path}:#{number}:#{line.rstrip}"
  end

  def repository_root
    File.expand_path("..", __dir__)
  end
end
