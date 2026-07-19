---
name: debitcredit-ledger
description: Maintain the debitcredit-ledger Rails engine gem. Covers setup, DB selection (SQLite/PostgreSQL), fixture-backed Minitest, loader/migration checks, gem build/inspect, and release prep without auto-publish.
---

# debitcredit-ledger

Double-entry accounting engine for Rails. Read `AGENTS.md` for full invariants.

## Invariants (do not violate)

- Distribution name `debitcredit-ledger`; require `require "debitcredit"`; namespace `Debitcredit`.
- `required_ruby_version ">= 4.0"`, `rails ">= 8.0"` — lower bounds only, never upper bounds.
- Preserve ledger behavior. No hardening (Issues #2–#8).
- Historical `db/migrate/*.rb` stays `Migration[4.2]`; do not edit it.
- No RubyGems publish.

## Setup / database / test

```sh
bundle install
DB=sqlite bundle exec rake debitcredit:install:migrations db:migrate
DB=sqlite      bundle exec rake test     # full suite; run on BOTH DBs
DB=postgresql  bundle exec rake test
bundle exec rake style                   # rubocop, 0 offenses
bundle exec rake dummy:boot              # Rails 8 + Debitcredit boot check
```

`DB` selects the database (default `sqlite`): `sqlite` or `postgresql`
(PostgreSQL via `DATABASE_URL` or `POSTGRES_HOST`/`POSTGRES_USER`/
`POSTGRES_PASSWORD`/`POSTGRES_DB`). Tests are fixture-backed Minitest under
`test/` (no RSpec); focus a file with `rails test path/to/test.rb`.

## Build / inspect

```sh
gem build debitcredit-ledger.gemspec     # pkg/debitcredit-ledger-<version>.gem
tar -tf pkg/debitcredit-ledger-*.gem
```

The gem must include `lib/debitcredit.rb`, `lib/debitcredit/{version,engine}.rb`,
`app/models/debitcredit/*.rb`, `db/migrate/*.rb`, `config/locales/en.yml`,
`MIT-LICENSE`, `Rakefile`, `README.md`, `CHANGELOG.md` and exclude `test/`,
`.github/`, `Gemfile.lock`, `*.gem`, `spec/`.

## Release prep (no auto-publish)

Publishing requires a separate approval gate (Trusted Publishing, green CI,
reviewed release diff, name-availability check). Align `Debitcredit::VERSION`
in `lib/debitcredit/version.rb` with `CHANGELOG.md`, verify on BOTH databases,
then build. Do not publish from this skill. Never add `< 9.0` Rails or
`< 5.0` Ruby bounds anywhere, even in comments.
