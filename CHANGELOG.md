# Changelog

## 1.0.0 (2026-07-18)

First release of the maintained `debitcredit-ledger` continuation. This is a
modernization of the original `vitaly/debitcredit` project (MIT) to Ruby 4.0+
and Rails 8.0+ lower bounds, fixture-backed Minitest, and SQLite plus
PostgreSQL CI. No ledger behavior changes were made. This release prepares the
artifact but does not claim a RubyGems publication.

## Prior history (original vitaly/debitcredit)

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

* 0.0.0.8
  - fix blocks on DSL

* 0.0.7
  - has_transactions with a block
  - has_transactions now defines :[](kind) on transactions association

* 0.0.6
  - include README in the gem

* 0.0.5
  - has_accounts and has_transactions extension

The original project was authored by Vitaly Kushner and remains covered by the
MIT license in `MIT-LICENSE`. The deferred modernization hardening backlog is
tracked in GitHub Issues #2 through #8.
