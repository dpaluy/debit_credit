# Debitcredit Ledger Modernization Design

**Date:** 2026-07-18  
**Status:** Approved for planning  
**Repository:** `dpaluy/debitcredit-ledger`

## Objective

Modernize the existing Rails engine without changing its ledger behavior. The release will establish `debitcredit-ledger` 1.0.0 as an independently maintained continuation of the original `vitaly/debitcredit` gem, support Ruby 4.0+ and Rails 8.0+ with lower bounds only, replace RSpec with Minitest, and verify SQLite and PostgreSQL through GitHub Actions.

Ledger-integrity hardening—including posted-record immutability, concurrency/idempotency changes, new database constraints, and reconciliation—is explicitly outside this modernization release and must be handled separately.

## Compatibility Contract

The gemspec will declare only lower bounds:

```ruby
spec.required_ruby_version = ">= 4.0"
spec.add_dependency "rails", ">= 8.0"
```

There will be no `< 5.0` Ruby ceiling and no `< 9.0` Rails ceiling. Documentation will distinguish declared compatibility from verified compatibility: the GitHub Actions matrix defines combinations tested by the project, while later compatible versions remain installable.

The distribution name becomes `debitcredit-ledger`, while source compatibility remains:

```ruby
require "debitcredit"
Debitcredit::Entry
Debitcredit::Account
```

`Debitcredit::VERSION` resets to `1.0.0`. The README, changelog, gemspec metadata, and release notes will state that this project is a maintained fork/continuation of the original MIT-licensed `vitaly/debitcredit` gem. Vitaly Kushner's copyright and attribution remain intact.

## Packaging

Rename `debitcredit.gemspec` to `debitcredit-ledger.gemspec` and modernize it with:

- HTTPS homepage and canonical repository URLs
- source-code, issue-tracker, changelog, and documentation metadata
- `rubygems_mfa_required`
- distinct summary and description
- deterministic package contents
- explicit Ruby and Rails lower bounds
- Minitest and database adapter development dependencies

Remove obsolete RSpec, Travis CI, Byebug, and deprecated Rails task configuration. Retain `docile` for this modernization pass unless removal is proven behavior-neutral by the converted test suite; dependency reduction beyond obsolete tooling is secondary to preserving behavior.

The built artifact must contain the library, engine models, migrations, locale, README, changelog, and license while excluding tests, CI files, local databases, logs, and generated gem artifacts.

## Rails 8 Dummy Application

Replace `spec/test_app` with a newly generated, minimal Rails 8 API-only application at `test/dummy`.

The dummy application will:

- load Rails 8 defaults
- mount/load the engine through the local gem
- contain only the host `User` model and schema needed by engine tests
- select SQLite or PostgreSQL through `DB`
- avoid asset, JavaScript, mailer, job, and browser-test components that the engine does not use

Database selection:

- `DB=sqlite` uses a local SQLite test database
- `DB=postgresql` uses standard PostgreSQL environment variables with CI-safe defaults

The dummy app is test infrastructure, not a distributable example application.

## Minitest Conversion

Replace `spec/` with `test/` and convert all four existing model suites plus their helpers to traditional Minitest backed by fixtures.

Required preserved behavior includes:

- account kinds and lookup
- account creation through associations
- overdraft validation
- total-balance checks
- entry DSL fields and balanced/unbalanced validation
- account balance updates on entry creation
- overdraft failure rollback
- symbol-based account references
- entry inversion defaults and parent linkage
- item inversion
- extension association proxy methods

The conversion must not intentionally change runtime behavior. Characterization tests should fail before the obsolete RSpec harness is removed or, where direct one-for-one execution is impossible, the converted Minitest suite must be shown to exercise the same fixture scenarios and assertions before cleanup.

Primary commands:

```bash
DB=sqlite bundle exec rake test
DB=postgresql bundle exec rake test
```

A Rails boot/loader check and migration setup must also be available through documented commands.

## GitHub Actions

Add least-privilege workflows for pull requests and pushes.

The required test matrix will run:

- Ruby 4.x with the supported Rails 8 dependency resolution
- SQLite
- PostgreSQL

Each database job must install dependencies, prepare the dummy database, and run the same Minitest suite. Additional jobs will verify Ruby syntax/style, gem build, package contents, local gem installation, and `require "debitcredit"`.

CI will not claim MySQL support. A GitHub issue will track MySQL as a future adapter after detachment and issue enablement.

## Repository Agent Guidance

Create a root `AGENTS.md` as the repository's authoritative agent contract. It will define:

- project identity and fork attribution
- compatibility policy and prohibition on adding upper bounds
- package name versus Ruby namespace
- supported databases
- fixture-backed Minitest policy
- historical migration preservation rule
- setup, test, lint, build, and smoke commands
- required verification before completion
- modernization-only scope for this release

Create `skills/debitcredit-ledger/SKILL.md` with valid YAML frontmatter and an actionable workflow for:

- initial setup
- selecting SQLite or PostgreSQL
- preparing the Rails 8 dummy app database
- running focused and full Minitest checks
- running loader and migration checks
- building and inspecting the gem
- preparing a release without publishing automatically

`AGENTS.md` will direct agents maintaining this gem to read the repository skill before acting. The skill will remain repository-local and committed with the project.

## Fork Detachment

The owner used GitHub's supported **Leave fork network** operation on 2026-07-18. Verification after the operation showed:

- `dpaluy/debitcredit-ledger` is public and reports `isFork=false`
- `parent` and `source` are null
- network count is zero
- local and remote `master` both point to `fc08994b24395e123c2e772d4b9d6b187e123138`

Git history was preserved. The repository is now an independent project and cannot be reconnected to the former fork network. GitHub Issues remained disabled after detachment and must be enabled before creating the project backlog or modernization pull request.

## GitHub Issues and Deferred Work

GitHub Issues is the source of truth for every future improvement that is intentionally deferred from this modernization release. Deferred work must not remain only in prose, chat history, the design document, or agent memory.

After enabling Issues, create an initial backlog with one focused issue per independently deliverable improvement:

1. `Add MySQL support and CI coverage`
   - MySQL service in GitHub Actions
   - dummy-app database configuration
   - migration compatibility
   - decimal, locking, and transaction behavior
   - the same Minitest suite passing without weakening SQLite or PostgreSQL
2. `Prevent posted entries and items from mutating or being destroyed`
   - enforce immutability or safe reversal-only correction
   - prevent stored account balances from becoming stale
3. `Harden inverse-entry validation and concurrent reversal handling`
   - graceful missing-parent validation
   - database-backed uniqueness and concurrent-attempt coverage
4. `Strengthen entry and item validation`
   - reject empty entries
   - return validation errors rather than exceptions for malformed amounts
   - define zero-amount behavior
5. `Modernize ledger schema constraints and identifier widths`
   - bigint-compatible identifiers
   - foreign keys and non-null constraints
   - collision-safe index names and polymorphic type width
6. `Harden concurrent account creation and balance verification`
   - race-safe lookup/creation
   - define and test the consistency semantics of global balance checks
7. `Add idempotent posting and ledger reconciliation`
   - caller-provided idempotency contract
   - drift detection and safe derived-balance rebuild

Each issue must include motivation, current evidence, proposed acceptance criteria, and the modernization release boundary. Issues may be split further during implementation, but unrelated improvements must not be bundled into one catch-all ticket.

## Documentation

Rewrite README setup and development sections to cover:

- installation as `debitcredit-ledger`
- unchanged `require "debitcredit"` and Ruby namespace
- Rails 8.0+ and Ruby 4.0+ lower-bound policy
- verified CI combinations
- SQLite and PostgreSQL support
- migration installation
- original-gem attribution and maintained-fork status

Rename `CHANGELOG` to `CHANGELOG.md`, establish `1.0.0` as the new distribution's first release, and accurately describe the prior repository history without claiming unpublished versions were released to RubyGems.

## Release Boundary

This design prepares the repository and artifact but does not publish to RubyGems. Publishing remains a separate approval gate and requires RubyGems Trusted Publishing, successful CI, a reviewed release diff, and confirmation that the `debitcredit-ledger` name is still available.

## Acceptance Criteria

The modernization is complete when:

- repository is verified standalone after GitHub detachment
- package builds as `debitcredit-ledger` 1.0.0
- Ruby and Rails gemspec requirements have lower bounds only
- `require "debitcredit"` succeeds from the installed artifact
- the Rails 8 API-only dummy app boots
- fixture-backed Minitest passes on SQLite and PostgreSQL
- no tracked RSpec or Travis references remain except historical explanatory prose where necessary
- gem build and install smoke checks pass without warnings
- `AGENTS.md` and `skills/debitcredit-ledger/SKILL.md` are present and internally consistent
- README and changelog identify the project as a maintained fork of the original gem
- GitHub Issues is enabled and every deferred improvement listed in this design has a verified issue URL
- no RubyGems publication occurs without separate approval
