# debitcredit-ledger — Agent Contract

This file is the authoritative agent contract for the `debitcredit-ledger`
repository. Read it (and `skills/debitcredit-ledger/SKILL.md`) before acting.

## Project identity

- **Distribution/gem name:** `debitcredit-ledger`
- **Ruby namespace:** `Debitcredit`
- **Require path:** `require "debitcredit"`

Do NOT rename the Ruby namespace or the require path. Only the gem/distribution
name is `debitcredit-ledger`; source compatibility stays `require "debitcredit"`.

## Compatibility policy (non-negotiable)

```ruby
spec.required_ruby_version = ">= 4.0"
spec.add_dependency "rails", ">= 8.0"
```

Lower bounds only. NEVER add a `< 5.0` Ruby ceiling or a `< 9.0` Rails ceiling
anywhere (gemspec, Gemfile, CI comments, README). The GitHub Actions matrix
defines *verified* combinations; later compatible versions remain installable.

## Supported databases

SQLite and PostgreSQL (select via `DB=sqlite` / `DB=postgresql`). MySQL is
deferred work tracked in Issue #2 — do not add it.

## Scope: modernization only

This release is modernization, NOT hardening. Any ledger behavior change is a
bug. Ledger-integrity hardening is deferred and tracked in GitHub Issues #2–#8:

- #2 Add MySQL support and CI coverage
- #3 Prevent posted entries and items from mutating or being destroyed
- #4 Harden inverse-entry validation and concurrent reversal handling
- #5 Strengthen entry and item validation
- #6 Modernize ledger schema constraints and identifier widths
- #7 Harden concurrent account creation and balance verification
- #8 Add idempotent posting and ledger reconciliation

Do not bundle any of these into a modernization change.

## Historical migration preservation rule

Do NOT edit historical `db/migrate/*.rb` content. The historical migrations use
`Migration[4.2]` and must stay that way. New dummy-app migrations use the
current `[8.0]`.

## Fixture-backed Minitest policy

Tests are traditional Rails fixture-backed Minitest under `test/`. There is no
RSpec. Run the full suite on BOTH databases before accepting a change.

## Setup

```sh
bundle install
DB=sqlite bundle exec rake debitcredit:install:migrations
DB=sqlite bundle exec rake db:migrate
```

## Verification commands (run before completion)

```sh
DB=sqlite      bundle exec rake test      # must pass
DB=postgresql  bundle exec rake test      # must pass
bundle exec rake style                    # rubocop, 0 offenses
gem build debitcredit-ledger.gemspec      # no warnings
bundle exec rake dummy:boot               # Rails 8 + Debitcredit boot check
! grep -RIn --exclude-dir=.git -e 'rspec' -e 'travis' -e 'byebug' app/ lib/ test/ Rakefile Gemfile debitcredit-ledger.gemspec
! grep -RIn '< 5.0\|< 9.0' --include='*.gemspec' --include='Gemfile*' .
git status --short                         # must be clean
```

## Release boundary

This repository prepares and verifies only. **No RubyGems publish** without a
separate approval gate (Trusted Publishing, green CI, reviewed release diff,
name-availability confirmation).

## Before you act

Read `skills/debitcredit-ledger/SKILL.md`.
