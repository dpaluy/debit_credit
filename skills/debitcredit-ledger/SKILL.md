---
name: debitcredit-ledger
description: Maintain the debitcredit-ledger Rails engine gem. Covers setup, DB selection (SQLite/PostgreSQL), fixture-backed Minitest, loader/migration checks, gem build/inspect, and release prep without auto-publish.
---

# debitcredit-ledger repository skill

`debitcredit-ledger` is a maintained continuation of the original
MIT-licensed `vitaly/debitcredit` double-entry accounting engine for Rails.

Read `AGENTS.md` first. It holds the non-negotiable invariants (gem name vs
namespace, lower-bound-only compatibility, modernization-only scope, historical
migration preservation).

## Invariants (do not violate)

- Distribution name: `debitcredit-ledger`. Require path: `require "debitcredit"`. Namespace: `Debitcredit`.
- `Debitcredit::VERSION == "1.0.0"`.
- `required_ruby_version ">= 4.0"`, `rails ">= 8.0"`. Never add upper bounds.
- Preserve ledger behavior. No hardening (Issues #2–#8).
- Historical `db/migrate/*.rb` stays `Migration[4.2]`. Do not edit it.
- No RubyGems publish.

## Initial setup

```sh
bundle install
```

Bundle resolves Rails 8.x locally. CI verifies the documented matrix.

## Select the database

All test/load commands read the `DB` environment variable (default `sqlite`):

- `DB=sqlite` — local SQLite file at `test/dummy/db/test.sqlite3`
- `DB=postgresql` — PostgreSQL via `DATABASE_URL` or the `POSTGRES_*` env vars
  with CI-safe defaults (host `localhost`, user `postgres`, db
  `debitcredit_test`).

## Prepare the Rails 8 dummy database

```sh
DB=sqlite bundle exec rake debitcredit:install:migrations
DB=sqlite bundle exec rake db:migrate
```

For PostgreSQL, provision a role/db matching the `database.yml` pg defaults,
then run the same commands with `DB=postgresql`.

## Loader / boot check

```sh
bundle exec rake dummy:boot
# prints Rails 8.x version + Debitcredit::VERSION, exits 0
```

## Run Minitest

```sh
DB=sqlite      bundle exec rake test     # full suite
DB=postgresql  bundle exec rake test     # same suite on PostgreSQL
DB=sqlite bundle exec rails test test/models/debitcredit/account_test.rb   # focused file
```

Tests are traditional Rails fixture-backed Minitest. Both databases MUST pass.

## Style

```sh
bundle exec rake style     # or: bundle exec rubocop
```

`.rubocop.yml` excludes `vendor/**/*`, `test/dummy/**/*`, `pkg/**/*`,
`Gemfile.lock`, and `node_modules/**/*` so vendored CI dependencies and the
generated dummy app are not linted.

## Build and inspect the gem

```sh
gem build debitcredit-ledger.gemspec      # produces pkg/debitcredit-ledger-1.0.0.gem
tar -tf pkg/debitcredit-ledger-1.0.0.gem
```

The package must contain `lib/debitcredit.rb`, `lib/debitcredit/version.rb`,
`lib/debitcredit/engine.rb`, `app/models/debitcredit/*.rb`, `db/migrate/*.rb`,
`config/locales/en.yml`, `MIT-LICENSE`, `Rakefile`, `README.md`,
`CHANGELOG.md` — and must exclude `test/`, `.github/`, `Gemfile.lock`,
`*.gem`, `pkg/`, `spec/`.

## Install smoke (throwaway GEM_HOME)

```sh
rm -rf /tmp/dc-gemhouse
gem install --install-dir /tmp/dc-gemhouse --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME=/tmp/dc-gemhouse ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry; puts Debitcredit::Account'
```

## Prepare a release WITHOUT auto-publish

Publishing to RubyGems requires a separate approval gate (Trusted Publishing,
green CI, reviewed release diff, name-availability check). Do not publish from
this skill. To prepare:

1. Ensure `Debitcredit::VERSION` matches the intended release in
   `lib/debitcredit/version.rb` and `CHANGELOG.md`.
2. Run the full verification block from `AGENTS.md` on BOTH databases.
3. Build the gem and run the install smoke above.
4. Record the gem SHA/size; stop. Do not push to RubyGems.

## Pitfalls

- **CI `vendor/bundle`**: GitHub Actions may install gems under a repo-local
  `vendor/bundle`. `.rubocop.yml` excludes it; if you change the exclude list,
  re-run `bundle exec rubocop` with `bundle config set path vendor/bundle`
  before pushing.
- **Rails upper bounds**: never add `< 9.0` anywhere, even in comments.
- **RSpec/Travis/byebug**: no tracked references in active code; only
  historical prose in README/CHANGELOG is allowed.
