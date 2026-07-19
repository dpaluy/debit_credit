# debitcredit-ledger

Double-entry accounting for Rails applications.

```ruby
require "debitcredit"
Debitcredit::Entry
Debitcredit::Account
```

The distribution/gem name is `debitcredit-ledger`; the Ruby namespace is
`Debitcredit` and the require path is `require "debitcredit"`.

## Installation

Add the gem to your Gemfile:

```ruby
gem "debitcredit-ledger"
```

Then run:

```sh
bundle install
bundle exec rake debitcredit:install:migrations db:migrate
```

## Compatibility

Declared bounds are **lower bounds only**:

- Ruby `>= 4.0`
- Rails `>= 8.0`

There are no upper bounds. Later compatible versions remain installable. The
GitHub Actions CI matrix defines the **verified** combinations:

- Ruby 4.x with Rails 8.x
- SQLite and PostgreSQL

No MySQL support yet (tracked in
[#2](https://github.com/dpaluy/debitcredit-ledger/issues/2)).

## Supported databases

Select the database with the `DB` environment variable (default `sqlite`):

```sh
DB=sqlite      bundle exec rake test
DB=postgresql  bundle exec rake test
```

PostgreSQL uses `DATABASE_URL` or the `POSTGRES_HOST`, `POSTGRES_USER`,
`POSTGRES_PASSWORD`, `POSTGRES_DB` environment variables.

## Development

```sh
bundle install
DB=sqlite bundle exec rake debitcredit:install:migrations
DB=sqlite bundle exec rake db:migrate
DB=sqlite bundle exec rake test      # fixture-backed Minitest
DB=postgresql bundle exec rake test
bundle exec rake style               # RuboCop, 0 offenses expected
bundle exec rake dummy:boot          # Rails + Debitcredit boot check
gem build debitcredit-ledger.gemspec # no warnings expected
```

Tests are fixture-backed Minitest. The test database is managed by a Rails 8
API-only dummy app at `test/dummy`.

See `AGENTS.md` and `skills/debitcredit-ledger/SKILL.md` for the agent contract
and repository workflow.

## Account Types, Debits and Credits

<http://en.wikipedia.org/wiki/Debits_and_credits>

In Double Entry Accounting there are 5 account types: Asset, Liability, Income,
Expense and Equity defined as follows:

**Asset** accounts are economic resources which benefit the business/entity and
will continue to do so. e.g. cash, bank, inventory, buildings, etc.

**Liability** accounts record debts or future obligations the business/entity
owes to others.

**Equity** accounts record the claims of the owners of the business/entity to
the assets of that business/entity. e.g. capital, retained earnings, drawings,
common stock, accumulated funds, etc.

**Income** is increases in economic benefits during the accounting period in the
form of inflows or enhancements of assets or decreases of liabilities that
result in increases in equity, other than those relating to contributions from
equity participants.

**Income** accounts record all increases in Equity other than that contributed
by the owner/s of the business/entity. e.g. services rendered, sales, interest
income, membership fees, rent income, etc.

**Expense** accounts record all decreases in the owners' equity which occur
from using the assets or increasing liabilities in delivering goods or services
to a customer - the costs of doing business. e.g. telephone, electricity,
salaries, depreciation, rent etc.

Debit and credit affect balance of an account differently depending on the
account type.

For Asset and Expense accounts, Debit increases the balance, and credit
decreases it. For the rest of the accounts it is the opposite. i.e. debit
decreases and credit increases the balance.

In each transaction sources are credited and destinations are debited.

I repeat: credit is the **source** and debit is the **destination**.

Personally, I was surprised to learn that. From my dealings with the bank I
expectred 'credit' to be the destination, becase each time my bank account is
'credited' I have more money in it.

The explanation for this is simple, your bank sees your account not as an
'asset', but as a 'liability', becase the balance on it is how much bank ows
you. That's why crediting this account increases it's balance.

## Accounting Equation

At any given point accounts should satisfy the following equation:

    Assets + Expenses = Liabilities + Equity + Income

You can verify it with `Account.balanced?`.

Debitcredit takes care to keep the system balanced at all times, if you get an
unbalanced state, its a bug, please report immediately!

## Accounts

The 5 types of accounts are represented by `Debitcredit::AssetAccount`,
`Debitcredit::LiabilityAccount`, `Debitcredit::IncomeAccount`, `Debitcredit::ExpenseAccount` and `Debitcredit::EquityAccount`

You can create standalone accounts:

    Debitcredit::AssetAccount.create name: 'asset'
    puts Debitcredit::Account[:asset].name

Or you can have a reference for the account:

    Debitcredit::AssetAccount.create name: 'asset', reference: User.first

Or

    class User
      has_many :accounts, as: :reference, class_name: 'Debitcredit::Account'
      ...
    end

    User.first.accounts.asset.create name: 'bank'
    puts User.first.accounts[:bank].name

Or better yet:

    class User
      include Debitcredit::Extension

      has_accounts
    end

By default accounts are prevented from having a negative balance, but you can
pass `overdraft_enabled: false` to allow it:

    Debitcredit::AssetAccount.create ..., overdraft_enabled: true

You can pass a block to `has_accounts` and to define referenced accounts:

    class User
      include Debitcredit::Extension

      has_accounts do
        income :salary
        expense :rent
        asset :checking, true # allow negative balance
      end
    end

    User.first.accounts.salary # will be created on first use

## Entries

You can prepare entries using DSL:

    t = Entry.prepare(description: 'rent payment') do
      debit expense_account, 100, "you can also provide a comment"
      credit bank_account, 50
      credit creditcard, 50
    end
    t.save!

Sum of the debits must be equal to the sum of the credits. Amounts can not be
negative.

You can create entries with a reference. For this case, and in case that
reference has 'accounts' association, you can use account names instead of objects:

    class User
      include Debitcredit::Extension

      has_accounts
      has_entries do
        def pay!
          ...
        end
      end
    end

    t = user1.entries.prepare(description: 'sale') do
      debit :checking, 100 # will use user1.accounts[:checking]
      credit user2.accounts[:checking], 100
    end

You can prepare an inverse entry. For example if you want to rollback an
existing entry:

    rollback = existing.inverse(kind: 'refund', description: 'item is out of stock')
    rollback.save!

### Overdraft

If an account doesn't allow overdraft (which is the default), no transaction
will be allowed to decrease the blance if result is negative. The 'decrease'
part is important, so that it's still ok to have a transaction that increases
the balance which was negative.

By default inverse entries are allowed to take accounts into overdraft even for
accounts with `overdraft_enabled: false`.  if this is undesirable, pass
`ignore_overdraft: false` to the `inverse` call.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/dpaluy/debitcredit-ledger/issues).

Deferred ledger-integrity hardening work is tracked in Issues
[#2](https://github.com/dpaluy/debitcredit-ledger/issues/2)–[#8](https://github.com/dpaluy/debitcredit-ledger/issues/8).

## License

This project is released under the MIT License. See [`MIT-LICENSE`](./MIT-LICENSE).
