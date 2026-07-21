# Changelog

## 1.0.0 (2026-07-18)

- The 1.0.0 identity uses the `debit_credit-ledger` distribution, the `DebitCredit` namespace, and the `require "debit_credit"` loader.
- Requires Ruby `>= 4.0` and Rails `>= 8.0` (lower bounds only).
- Test suite migrated from RSpec to fixture-backed Minitest under `test/`.
- Added a Rails 8 API-only dummy app at `test/dummy`.
- CI on GitHub Actions covers Ruby 4.x against SQLite and PostgreSQL.
- Added build, style (RuboCop), and install/require smoke jobs.
- Added `AGENTS.md` for repository guidance.

No ledger behavior changes in this release.
