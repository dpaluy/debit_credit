require_relative "lib/debitcredit/version"

Gem::Specification.new do |spec|
  spec.name = "debitcredit-ledger"
  spec.version = Debitcredit::VERSION
  spec.authors = ["Vitaly Kushner"]
  spec.email = ["vitaly@astrails.com"]
  spec.homepage = "https://github.com/dpaluy/debitcredit-ledger"
  spec.summary = "Double-entry accounting for Rails applications"
  spec.description = "A maintained fork and continuation of vitaly/debitcredit, providing double-entry accounting for Rails applications."
  spec.license = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/dpaluy/debitcredit-ledger",
    "bug_tracker_uri" => "https://github.com/dpaluy/debitcredit-ledger/issues",
    "changelog_uri" => "https://github.com/dpaluy/debitcredit-ledger/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/dpaluy/debitcredit-ledger#readme",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir[
    "{app,config,db,lib}/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.required_ruby_version = ">= 4.0"
  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "docile"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rubocop", "~> 1.88"
  spec.add_development_dependency "rubocop-minitest"
end
