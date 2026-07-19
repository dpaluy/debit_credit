# Changelog

## 1.0.0 (2026-07-18)

First release of the maintained `debitcredit-ledger` continuation. This is a
modernization of the original [`vitaly/debitcredit`](https://github.com/vitaly/debitcredit)
gem (MIT, © Vitaly Kushner), now maintained as an independent detached project.

- Distribution/gem name changed to `debitcredit-ledger`. The Ruby namespace
  (`Debitcredit`) and require path (`require "debitcredit"`) are unchanged.
- Ruby `>= 4.0` and Rails `>= 8.0` lower bounds only (no upper bounds).
- Replaced RSpec with fixture-backed Minitest under `test/`.
- Added a Rails 8 API-only dummy app at `test/dummy`.
- Verified SQLite and PostgreSQL through GitHub Actions CI.
- Least-privilege CI (Ruby 4.x × {sqlite, postgresql} + build/lint/install jobs).
- Added `AGENTS.md` + `skills/debitcredit-ledger/SKILL.md` agent guidance.
- Rewritten README with maintained-fork attribution.
- **No ledger behavior changes.** This is modernization, not hardening.

Deferred ledger-integrity hardening is tracked in Issues
[#2](https://github.com/dpaluy/debitcredit-ledger/issues/2)–[#8](https://github.com/dpaluy/debitcredit-ledger/issues/8).

Not published to RubyGems. Publishing requires a separate approval gate
(Trusted Publishing, green CI, reviewed release diff, name-availability check).

---

## Prior history (original vitaly/debitcredit)

The entries below document the history of the original `vitaly/debitcredit`
repository. These versions were not published to RubyGems under the
`debitcredit-ledger` name; they are preserved here for historical context.

* 1.1.6
  - Rails 6 fixes
  - fix specs

* 1.0.0
  - regenerated gem template with latest Rails (5.1.4)
  - removed spork (to be replaced by spring later)
  - Rails 5 fixes (for Rails 4 use 0.2.0).

* 0.2.0
  - support for rails >= 4.1
  - updarted README

* 0.1.1
  - installation instructions
  - child_transactions

* 0.1.0
  - added defaults for inversed transactions
  - added inverse_transaction_id

*.0.0.9
  - fixed name of the Dsl module
  - dsl methods to set kind, description and reference

*.0.0.8
  - fix blocks on DSL

* 0.0.7
  - has_transactions with a block
  - has_transactions now defines :[](kind) on transactions association

* 0.0.6
  - include README in the gem

* 0.0.5
  - has_accounts and has_transactions extension
