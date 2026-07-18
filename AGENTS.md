# debitcredit-ledger Agent Contract

Read `skills/debitcredit-ledger/SKILL.md` before acting.

## Project identity and invariants

- Distribution/gem name: `debitcredit-ledger`. Ruby namespace: `Debitcredit`. Require path: `require "debitcredit"`. Do NOT rename the namespace or require path.
- `Debitcredit::VERSION = "1.0.0"` (reset).
- `spec.required_ruby_version = ">= 4.0"`, `spec.add_dependency "rails", ">= 8.0"`. NEVER add `< 5.0` Ruby or `< 9.0` Rails upper bounds anywhere (gemspec, Gemfile, CI matrix comments, README). Later compatible versions remain installable; CI matrix defines verified combinations only.
- Preserve current ledger behavior. This is modernization, NOT hardening. Any behavior change is a bug. P0 hardening is deferred to GitHub Issues #2–#8.
- Fork attribution: Vitaly Kushner © (per `MIT-LICENSE`), MIT license preserved. README/changelog/gemspec metadata state this is a maintained fork/continuation of `vitaly/debitcredit`.
- No RubyGems release in this plan.

## Scope and preservation rules

This release is modernization only. Do not add immutability, concurrency, idempotency, reconciliation, new schema constraints, or other hardening. Do not modify historical files under `db/migrate/`. Preserve the existing ledger behavior and use the old specs and fixtures as the behavioral reference during the Minitest conversion.

Tests are fixture-backed Minitest under `test/`, not RSpec. Supported test databases are SQLite and PostgreSQL, selected with `DB=sqlite` or `DB=postgresql`. The Rails 8 API-only test application lives at `test/dummy`.

## Setup and verification

```bash
bundle install
DB=sqlite bundle exec rake debitcredit:install:migrations db:migrate
DB=sqlite bundle exec rake test
DB=postgresql bundle exec rake debitcredit:install:migrations db:migrate
DB=postgresql bundle exec rake test
bundle exec rake dummy:boot
bundle exec rake style
gem build debitcredit-ledger.gemspec
```

Before completion, record real output for:

```bash
git rev-parse HEAD
gh repo view dpaluy/debitcredit-ledger --json isFork,parent,defaultBranchRef --jq '{isFork,parent:(.parent.nameWithOwner // null),defaultBranch:.defaultBranchRef.name}'
DB=sqlite bundle exec rake test
DB=postgresql bundle exec rake test
bundle exec rake style
gem build debitcredit-ledger.gemspec
gem install --install-dir /tmp/dc-gemhouse-final --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME=/tmp/dc-gemhouse-final ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry'
bundle exec rake dummy:boot
! grep -RIn --exclude-dir=.git -e 'rspec' -e 'travis' -e 'byebug' app/ lib/ test/ Rakefile Gemfile debitcredit-ledger.gemspec
! grep -RIn '< 5.0\|< 9.0' --include='*.gemspec' --include='Gemfile*' .
gh issue list --repo dpaluy/debitcredit-ledger --state all --limit 20
```

## Working rules

- Commit at each modernization slice boundary with a clear message.
- Do not push or publish.
- Keep package contents deterministic and exclude test infrastructure, CI files, local databases, logs, and generated gem artifacts.
- Do not claim that historical unpublished versions were released to RubyGems.
