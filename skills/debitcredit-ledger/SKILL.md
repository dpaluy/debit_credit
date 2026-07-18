---
name: debitcredit-ledger
description: Maintain and verify the debitcredit-ledger Rails engine without changing ledger behavior.
---

# debitcredit-ledger workflow

Read the root `AGENTS.md` before acting. This repository is a maintained fork and continuation of `vitaly/debitcredit`. The distribution is `debitcredit-ledger`, while source compatibility remains `require "debitcredit"`, `Debitcredit::...`, and `Debitcredit::VERSION == "1.0.0"`.

## Initial setup

1. Use only the current worktree.
2. Run `bundle install`.
3. Do not modify historical files under `db/migrate/`.
4. Keep the MIT license and Vitaly Kushner attribution.
5. Keep Ruby and Rails requirements lower-bound only: Ruby `>= 4.0`, Rails `>= 8.0`. Never add Ruby `< 5.0` or Rails `< 9.0` ceilings.

## Database selection and preparation

Set `DB=sqlite` for the default local SQLite database or `DB=postgresql` for PostgreSQL. PostgreSQL uses `DATABASE_URL` when supplied, otherwise the dummy app's standard `POSTGRES_*` environment variables and CI-safe defaults.

For a fresh dummy database:

```bash
DB=sqlite bundle exec rake debitcredit:install:migrations db:migrate
DB=postgresql bundle exec rake debitcredit:install:migrations db:migrate
```

The Rails 8 API-only dummy app is under `test/dummy`. Check its loader without running tests:

```bash
DB=sqlite bundle exec rake dummy:boot
```

## Focused and full Minitest

Tests are fixture-backed Minitest. Run a focused test file with:

```bash
DB=sqlite bundle exec ruby -Itest test/models/debitcredit/account_test.rb
```

Run the complete suite on both supported databases with:

```bash
DB=sqlite bundle exec rake test
DB=postgresql bundle exec rake test
```

Do not weaken or skip characterization assertions, and do not introduce ledger hardening as part of modernization.

## Loader and migration checks

The engine must load through the local gem from the dummy app. Verify the version and a representative constant:

```bash
ruby -Ilib -e 'require "debitcredit"; abort unless Debitcredit::VERSION == "1.0.0"; puts Debitcredit::Entry'
DB=sqlite bundle exec rake dummy:boot
```

Install engine migrations into the dummy app, then migrate. Historical engine migration contents remain unchanged.

## Style, build, and gem inspection

Run style through the repository task:

```bash
bundle exec rake style
```

Build the artifact and inspect its contents:

```bash
gem build debitcredit-ledger.gemspec
tar -tf pkg/debitcredit-ledger-1.0.0.gem
```

The package contains library, engine models, historical migrations, locale, README, changelog, Rakefile, and MIT-LICENSE. It excludes `test/`, `.github/`, `spec/`, `Gemfile.lock`, `pkg/`, local databases, logs, and generated gem artifacts.

Verify the installed artifact in a throwaway home:

```bash
smoke_dir="$(mktemp -d)"
gem install --install-dir "$smoke_dir" --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME="$smoke_dir" ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION == "1.0.0"; puts Debitcredit::Entry'
```

## Release preparation

Release preparation includes clean slice commits, passing SQLite and PostgreSQL tests, style, warning-free gem build, package inspection, installed-artifact smoke, and documentation of maintained-fork attribution. Do not publish to RubyGems automatically. Publishing requires separate approval.
