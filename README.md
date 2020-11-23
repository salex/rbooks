## RBooks or {ou}RBooks or {Ro}RBooks

Is a Rails Double Entry Accounting application for Semi-Accountants.

#### A little history

I am not an Accountant nor a real Rails developer, just a hobbyist programmer who has used that knowledge to solve many *unique* problems over the last 50 years. Unique maybe a little strong, but I'm sure not many have had to developed applications that tracked how may times an Aircraft crew threw something (people, tank, pallet) out of the back of a C-130. Then there is developing a job screening process for companies building a new factory.  They seemed unique at the time, but they are just *bean* counting, sorting, filtering processes.

RBooks is the forth iteration of developing something to help *me* accomplish a job I volunteered for, a Quartermaster of a Veterans of Foreign Wars (VFW) post. One of the responsibilities of a Quartermaster is keeping the accounting books. This started of with a paper ledger that lasted about 3 months. I then moved to a GNUCash application (basically an Open Source version of QuickBooks). Then to a Ruby CLI application that used a copy of the GNUCash database to produce VFW specific reports. Then through 3 versions of a standalone RoR accounting application that put GNUCash to sleep. I use the term Semi-Accountant in that we do use an Accounting Service for taxes, etc, but I have to provide them the basic information (POS reports,ledgers, statements, receipts, etc.). RBooks helps me keep the stuff straight.

#### Overview

Enough history - RBooks implements the basic accounting equation

#### <b>Assets - Liabilities = Equity + (Income - Expenses)</b>

It does this using classic accounting models

```ruby
class Account < ApplicationRecord
  has_many :splits, dependent: :destroy
  has_many :entries, through: :splits, dependent: :destroy
end

class Entry < ApplicationRecord
  # classically called transaction (but reserved rails word)
  has_many :splits, -> {order(:account_id)},dependent: :destroy, inverse_of: :entry
end

class Split < ApplicationRecord
  belongs_to :entry, inverse_of: :splits
  belongs_to :account
end
```

The basic number one rule of accounting is that the accounting equation must balance.
* If you buy something, you must decrease an Asset and increase an Expense
* If you sell something, you must increase an Asset and decrease a Income
* Since Accountants are assbackwards, they use the terms Debit and Credit!

RBooks updates these models through Ledgers, which is just an Entry with at least two splits, one increasing some account and another decreasing another.

The Books in RBooks allows for multiple accounting books (e.g., your checking account and spouses or business). It does this by adding `belongs to Book` to Account and Entry models.

The Account model is a Tree with a Root account being the parent of the basic elements of the accounting equation [Assets, Liabilities, Equity, Income, Expenses]. From there, each account can contain many sub-accounts. Each account can have the following attributes.

* Children - direct descendants
* Branches - descendants that have children
* Leaves - descendants that do not have children
* Family - all descendants


#### Current attributes:

* Ruby version - 2.6.5
* Rails version - 6.0.3.4
* System dependencies
  *  gem 'pg'
  *  gem 'slim-rails'
  *  gem 'prawn'
  *  gem 'prawn-table'
  *  gem 'ofx', '~> 0.3.1' , github: 'annacruz/ofx', branch: 'master'
  *  gem 'font-awesome-sass', '~> 5.12.0'

I consider RBooks somewhere between QuickBooks and Quicken. You can balance/reconcile a checkbook but also get many other features not available in Quicken. It does not deal with Invoices or Purchase Orders and some other QuickBooks features, but it works for me.

There are a few VFW name-spaced optional models (Deposit, Inventory, Revenue and SalesItem) that illustrate how to add features that are specific to your needs.

You can see what some of the pages (e.g., ledger) look like in the /app/images directory

#### Installation or setup

*  clone repository into a directory then cd into it
*  bundle.install
*  bin/rails db:setup
*  bin/rails s

`db:setup` should create a new database and load the schema, then call seeds.db

`seeds.db` should create a new user 'reviewer' with a password 'letmein' then it will create a new book 

There is a fair 'About' link that gives a little more details on how things work.

Hope it works!



