require_relative "lib/debitcredit/version"

Gem::Specification.new do |s|
  s.name = "debitcredit-ledger"
  s.version = Debitcredit::VERSION

  s.authors = ["David Paluy"]
  s.email = ["david@paluy.com"]
  s.license = "MIT"

  s.summary = "Double-entry accounting for Rails applications"
  s.description = "Double-entry accounting engine for Rails. Provides typed " \
                  "accounts (asset, liability, equity, income, expense), " \
                  "balanced entries, references, and inverse/rollback entries."

  s.homepage = "https://github.com/dpaluy/debitcredit-ledger"
  s.metadata = {
    "source_code_uri" => "https://github.com/dpaluy/debitcredit-ledger",
    "bug_tracker_uri" => "https://github.com/dpaluy/debitcredit-ledger/issues",
    "changelog_uri" => "https://github.com/dpaluy/debitcredit-ledger/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/dpaluy/debitcredit-ledger#readme",
    "rubygems_mfa_required" => "true"
  }

  # Only lower bounds. Never add a Ruby or Rails upper bound.
  s.required_ruby_version = ">= 4.0"
  s.add_dependency "docile"
  s.add_dependency "rails", ">= 8.0"

  s.add_development_dependency "minitest"
  s.add_development_dependency "pg"
  s.add_development_dependency "rubocop", "~> 1.88"
  s.add_development_dependency "rubocop-minitest", "~> 0.39"
  s.add_development_dependency "sqlite3"

  # Deterministic package contents. Excludes tests, CI, lockfile, built gems.
  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md",
    "CHANGELOG.md"
  ]
  s.bindir = "exe"
  s.executables = s.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
