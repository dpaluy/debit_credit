# debitcredit-ledger

`debitcredit-ledger` is a maintained fork and continuation of the original
[`vitaly/debitcredit`](https://github.com/vitaly/debitcredit) project, originally
authored by Vitaly Kushner. It preserves the original MIT license and ledger
behavior while modernizing the development and test tooling.

## Installation

Add the maintained distribution to your Gemfile:

```ruby
gem "debitcredit-ledger"
```

Then run:

```bash
bundle install
bundle exec rake debitcredit:install:migrations db:migrate
```

The distribution name is new, but source compatibility is unchanged:

```ruby
require "debitcredit"

Debitcredit::Entry
Debitcredit::Account
```

The current release is `1.0.0`. The gemspec declares Ruby 4.0+ and Rails 8.0+
as lower bounds only. Later compatible versions remain installable. The CI
matrix verifies Ruby 4.0 with Rails 8.x, rather than defining the full range of
installable versions.

SQLite and PostgreSQL are supported by the test application. Select the
adapter with `DB=sqlite` or `DB=postgresql`:

```bash
DB=sqlite bundle exec rake test
DB=postgresql bundle exec rake test
```

PostgreSQL uses `DATABASE_URL` when supplied, or the standard `POSTGRES_HOST`,
`POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` variables.

## Development

The Rails 8 API-only dummy application is in `test/dummy`. Prepare its
database with:

```bash
DB=sqlite bundle exec rake debitcredit:install:migrations db:migrate
DB=sqlite bundle exec rake dummy:boot
bundle exec rake style
```

Tests are fixture-backed Minitest. Run one file directly or run the complete
suite on both supported databases. The gem can be built and smoke-tested
without publishing it:

```bash
mkdir -p pkg
gem build debitcredit-ledger.gemspec --output pkg/debitcredit-ledger-1.0.0.gem
smoke_dir="$(mktemp -d)"
gem install --install-dir "$smoke_dir" --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME="$smoke_dir" ruby -e 'require "debitcredit"; puts Debitcredit::Entry'
```

The deferred hardening backlog is tracked in GitHub Issues #2 through #8.
Those issues cover future adapter support, immutability, validation,
concurrency, schema constraints, idempotency, and reconciliation. They are
outside the modernization release boundary.

## Account Types, Debits and Credits

In double-entry accounting there are five account types: Asset, Liability,
Income, Expense, and Equity.

**Asset** accounts are economic resources which benefit the business or entity
and will continue to do so, such as cash, bank accounts, inventory, and
buildings.

**Liability** accounts record debts or future obligations owed to others.

**Equity** accounts record the owners' claims on the assets of the business,
such as capital, retained earnings, drawings, common stock, and accumulated
funds.

**Income** records increases in economic benefits during an accounting period,
other than contributions from equity participants. Income accounts record
increases in equity from services, sales, interest, membership fees, rent, and
similar sources.

**Expense** accounts record decreases in owners' equity caused by using assets
or increasing liabilities while delivering goods or services, including
telephone, electricity, salaries, depreciation, and rent.

Debit and credit affect an account balance differently depending on its type.
For Asset and Expense accounts, a debit increases the balance and a credit
decreases it. For Liability, Equity, and Income accounts, a debit decreases the
balance and a credit increases it.

In each entry, sources are credited and destinations are debited. Credit is
the source and debit is the destination. A bank sees a customer's account as a
liability, which is why crediting that account increases its balance.

## Accounting Equation

At any given point, accounts should satisfy:

```text
Assets + Expenses = Liabilities + Equity + Income
```

You can verify this with `Debitcredit::Account.balanced?`. Debitcredit keeps
the system balanced when entries are posted.

## Accounts

The five account types are represented by:

- `Debitcredit::AssetAccount`
- `Debitcredit::LiabilityAccount`
- `Debitcredit::IncomeAccount`
- `Debitcredit::ExpenseAccount`
- `Debitcredit::EquityAccount`

Create a standalone account:

```ruby
Debitcredit::AssetAccount.create!(name: "asset")
puts Debitcredit::Account[:asset].name
```

An account may have a reference:

```ruby
Debitcredit::AssetAccount.create!(name: "asset", reference: User.first)
```

Or an application can use the extension:

```ruby
class User < ActiveRecord::Base
  include Debitcredit::Extension

  has_accounts do
    income :salary
    expense :rent
    asset :checking, true # allow a negative balance
  end
end

User.first.accounts.salary
```

By default, accounts are prevented from having a negative balance. Pass
`overdraft_enabled: true` when an account may go into overdraft.

## Entries

Entries can be prepared with the DSL:

```ruby
entry = Debitcredit::Entry.prepare(description: "rent payment") do
  debit expense_account, 100, "optional comment"
  credit bank_account, 50
  credit creditcard, 50
end
entry.save!
```

The debit and credit totals must match, and amounts cannot be negative.

An entry with a reference can use account names when the reference provides an
`accounts` association:

```ruby
class User < ActiveRecord::Base
  include Debitcredit::Extension
  has_accounts
  has_entries
end

entry = user1.entries.prepare(description: "sale") do
  debit :checking, 100
  credit user2.accounts[:checking], 100
end
```

To prepare an inverse entry, such as a rollback:

```ruby
rollback = existing.inverse(kind: "refund", description: "item is out of stock")
rollback.save!
```

### Overdraft

If an account does not allow overdraft, an entry cannot decrease its balance
below zero. An entry that increases an already negative balance is still valid.
By default, inverse entries may take accounts into overdraft, even when
`overdraft_enabled` is false. Pass `ignore_overdraft: false` to `inverse` when
that behavior is not desired.

## Attribution and License

This project is a maintained fork and continuation of `vitaly/debitcredit`.
The original project was authored by Vitaly Kushner. Copyright and the MIT
license attribution are preserved in [`MIT-LICENSE`](MIT-LICENSE).
