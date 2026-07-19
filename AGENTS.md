# Repository Guidelines

## Project Structure & Module Organization

This repository packages `debitcredit-ledger`, a Rails engine for double-entry accounting. Runtime models live in `app/models/debitcredit/`; engine loading and version files live in `lib/debitcredit/`. Keep the public require path `require "debitcredit"` and the Ruby namespace `Debitcredit`. Database migrations are under `db/migrate/`, locale data under `config/locales/`, and Rake tasks under `lib/tasks/`.

Tests live in `test/`, with model tests in `test/models/debitcredit/`, fixtures in `test/fixtures/`, shared helpers in `test/support/`, and the Rails host application in `test/dummy/`. Do not edit historical engine migrations; they intentionally retain `ActiveRecord::Migration[4.2]`.

## Build, Test, and Development Commands

- `bundle install` installs gem dependencies.
- `DB=sqlite bundle exec rake debitcredit:install:migrations db:migrate` prepares local SQLite development data.
- `DB=sqlite bundle exec rake test` runs the full suite against SQLite.
- `DB=postgresql bundle exec rake test` verifies PostgreSQL behavior; configure `DATABASE_URL` or the documented `POSTGRES_*` variables.
- `bundle exec rake style` runs RuboCop; expect zero offenses.
- `bundle exec rake dummy:boot` checks Rails and engine initialization.
- `gem build debitcredit-ledger.gemspec` builds the distributable gem.

## Coding Style & Naming Conventions

Use two-space Ruby indentation, double-quoted strings in new code, `snake_case` methods and files, and `CamelCase` classes/modules. Follow nearby historical style when touching engine code, and avoid unrelated formatting. See `.rubocop.yml` for intentional legacy exclusions.

## Testing Guidelines

Tests use Rails fixture-backed Minitest, not RSpec. Name files `*_test.rb` and write descriptive `test "behavior" do` cases. Add focused regression coverage for behavior changes. Run a single file with `DB=sqlite bundle exec rails test test/models/debitcredit/entry_test.rb`, then verify the full suite on both supported databases.

## Commit & Pull Request Guidelines

Follow the history’s concise, imperative commit subjects, such as `Add ...`, `Remove ...`, or `Rewrite ...`; keep each commit focused. Pull requests should explain the user-visible effect, identify database impact, and list exact verification commands.
