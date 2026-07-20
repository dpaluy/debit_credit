# Repository Guidelines

## Project Structure & Module Organization

This repository packages `debit_credit-ledger`, a Rails engine for double-entry accounting. Runtime models live in `app/models/debit_credit/`; engine loading and version files live in `lib/debit_credit/`. Keep the public require path `require "debit_credit"` and the Ruby namespace `DebitCredit`. Database migrations are under `db/migrate/`, locale data under `config/locales/`, and Rake tasks under `lib/tasks/`.

Tests live in `test/`, with model tests in `test/models/debit_credit/`, fixtures in `test/fixtures/`, shared helpers in `test/support/`, and the Rails host application in `test/dummy/`. The gem is Rails 8-only, so the single engine migration under `db/migrate/` and the dummy host migration under `test/dummy/db/migrate/` both inherit `ActiveRecord::Migration[8.0]`. The engine ships exactly one create-only migration that builds the final `debit_credit_accounts`, `debit_credit_entries`, and `debit_credit_items` schema directly; there is no historical migration chain, compatibility migration, or upgrade path because 1.0.0 is unreleased.

## Build, Test, and Development Commands

- `bundle install` installs gem dependencies.
- `DB=sqlite bundle exec rake debit_credit:install:migrations db:migrate` prepares local SQLite development data.
- `DB=sqlite bundle exec rake test` runs the full suite against SQLite.
- `DB=postgresql bundle exec rake test` verifies PostgreSQL behavior; configure `DATABASE_URL` or the documented `POSTGRES_*` variables.
- `bundle exec rake style` runs RuboCop; expect zero offenses.
- `bundle exec rake dummy:boot` checks Rails and engine initialization.
- `gem build debit_credit-ledger.gemspec` builds the distributable gem.

## Coding Style & Naming Conventions

Use two-space Ruby indentation, double-quoted strings in new code, `snake_case` methods and files, and `CamelCase` classes/modules. Follow nearby historical style when touching engine code, and avoid unrelated formatting. See `.rubocop.yml` for intentional legacy exclusions.

## Testing Guidelines

Tests use Rails fixture-backed Minitest, not RSpec. Name files `*_test.rb` and write descriptive `test "behavior" do` cases. Add focused regression coverage for behavior changes. Run a single file with `DB=sqlite bundle exec rails test test/models/debit_credit/entry_test.rb`, then verify the full suite on both supported databases.

## Commit & Pull Request Guidelines

Follow the history’s concise, imperative commit subjects, such as `Add ...`, `Remove ...`, or `Rewrite ...`; keep each commit focused. Pull requests should explain the user-visible effect, identify database impact, and list exact verification commands.
