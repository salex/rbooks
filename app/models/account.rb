class Account < ApplicationRecord
  attribute :transfer
  attribute :leafs

  has_many :splits, dependent: :destroy
  has_many :entries, through: :splits, dependent: :destroy
  belongs_to :book
  belongs_to :parent, foreign_key: :parent_id, class_name: 'Account', optional: true
  validates_uniqueness_of :code, allow_blank: true
  validates :name, presence: true
  validates :parent_id, presence: true, unless: :root_account?
  validates :account_type, inclusion: { in: ACCT_TYPES,message: "%{value} is not a valid account type" }

  after_save :set_acct_updated
  after_destroy :set_acct_updated
  after_touch :set_acct_updated

  def set_acct_updated
    atime = Time.now.utc.to_s
    Rails.application.config.x.acct_updated = atime
    self.book.get_settings # fires method that resets settings in Rails.application.config.x.settings
  end

  def destroyable?
    self.children.blank? && self.entries.blank?
  end

  def parent
    Account.find(self.parent_id) unless root_account?
  end

  def root_account?
    self.uuid == self.book.root
  end

  def flipper
    # defines normal credit balance
    #TODO  implement contra * -1 if self.contra
    pm = %{INCOME EQUITY LIABILITY}.include?(self.account_type)  ? -1 : 1

  end

  def family_tree_ids
    # Only used in last_entry_date to get the lall entries for the family and me
    # if self is a leaf (no childre) it will be an array [:id]
    # if self has children it will be array [:id,e0.id, e1.id, etc]
    self.family.pluck(:id) << self.id
  end


  def last_entry_date
    e = Entry.where_assoc_exists(:splits,{ account_id: family_tree_ids})
    .includes(:splits)
    .order(:post_date).last
    if e.present?
      e.post_date
    else
      Date.today.beginning_of_year
    end
  end

  def walk_tree(level,new_tree)
    self.level = level
    self.transfer = self.long_account_name
    new_tree << self
    level += 1
    self.children.each do |child|
      child.walk_tree(level,new_tree)
    end
    level -= 1
    new_tree
  end

  def leaf(leaf_array=[])
    if self.leafs.present?
      # p "GETTING LEAFS"
      return self.leafs 
    else
      # p "SETTING LEAFS"
      self.children.each do |c|
        unless c.has_children?
          leaf_array << c.id
        end
        c.leaf(leaf_array)
      end
      self.leafs = leaf_array
    end
  end

  
  def children
    self.book.accounts.where(parent_id:self.id).order(:name)

  end

  def has_children?
    !children.blank?
  end


  def family
    kids = children
    kids.each do |child|
      kids += child.family
    end
    kids
  end

  def branches(branch_array=[])
    self.children.each do |c|
      if c.has_children?
        branch_array << c.id
      end
      c.branches(branch_array)
    end
    branch_array
  end

  def long_account_name(reverse=false)
    account_name = self.name
    the_parent = self.parent 
    while the_parent.present? && the_parent.account_type != 'ROOT'
      if reverse
        account_name = account_name + ":" + the_parent.name
      else
        account_name = the_parent.name + ":" + account_name
      end
      the_parent = the_parent.parent
    end
    # for data_lookup
    account_name = "#{account_name}[#{self.id}]" if reverse
    return account_name
  end

=begin Balances
  There are three types of balances
  balance = balance (sum of all split) for only the account
  children_balance = balance for only the children (one generation) of the account, if there are any.
  family_balance = balance for the account (only if account is not a placeholder) and the all decendents

  each of the balances have extensions
  on(date) ending balances on the date (entries.post_date <= date)
  TODO this was a change when there was opeing and closing balalance in icash went to just on I don;t thing there is 
    a need for opening balalance (whiich is was before) it worked for everyting except renconcile.
    the todo is just to keep and eye out for problems
  between(from,to) balances between the from and to date

  Some of these balances are probably not needed unless your trying to answer some stupid question
  UPDATE, got rid of most of those with icash > rbooks

  there are some alias methods link starting.. ending.. which are on balance_on 

  By default: if an account has children, you can't create and entry using that account under normal circumstances
  If you decide to split an account and don't place it under a new parent there could be entries in a placeholder
  this is allowed in gnucash, I don't allow anyting to be added, but entries that exist and will balance

=end


    def balance
      bal = self.splits.sum(:amount)  * self.flipper
    end

    def balance_on(date)
      date = Ledger.set_date(date)
      self.splits.joins(:entry).where(Entry.arel_table[:post_date].lt(date)).sum(:amount) * self.flipper
    end

  # most  these below balances are no longer used
    #What the used to do has been replaced by the summary methods (child family)

    def balance_between(from,to)
      from = Ledger.set_date(from)
      to = Ledger.set_date(to)
      self.splits.joins(:entry).where(entries: {post_date:[from..to]}).sum(:amount) * self.flipper
    end

    alias starting_balance_on balance_on
    alias ending_balance_on balance_on
    alias closing_balance_on balance_on

    def children_balance
      bal = 0
      self.children.each do |child|
        bal += child.balance
      end
      bal
    end

    def children_balance_on(date)
      date = Ledger.set_date(date)
      bal = 0
      self.children.each do |child|
        bal += child.balance_on(date)
      end
      bal
    end

    def children_balance_between(from,to)
      from = Ledger.set_date(from)
      to = Ledger.set_date(to)
      bal = 0
      self.children.each do |child|
        bal += child.balance_between(from,to)
      end
      bal
    end

    alias closing_children_balance_on children_balance_on

    def family_balance
      bal = balance
      bal += family_child_balance
    end

    def family_balance_on(date)
      date = Ledger.set_date(date)
      bal = balance_on(date)
      bal += family_child_balance_on(date)
    end

    def family_balance_between(from,to)
      date = Ledger.set_date(date)
      bal = balance_between(from,to)
      bal += family_child_balance_between(from,to)
    end


    def family_child_balance
      bal = 0
      self.children.each do |child|
        bal += child.balance
        bal += child.family_child_balance
      end
      bal
    end

    def family_child_balance_on(date)
      date = Ledger.set_date(date)
      bal = 0
      self.children.each do |child|
        bal += child.balance_on(date)
        bal += child.family_child_balance_on(date)
      end
      bal
    end

    def family_child_balance_between(from,to)
      from = Ledger.set_date(from)
      to = Ledger.set_date(to)
      bal = 0
      self.children.each do |child|
        bal += child.balance_between(from,to)
        bal += child.family_child_balance_between(from,to)
      end
      bal
    end

    # Summaries and ledgers

    def family_summary(from,to)
      id = self.id
      root = {id => self.summary(from,to)}
      branches = Account.includes(:book).where(id:self.branches)
      branches.each do |b|
        root[b.id] = b.summary(from,to)
      end
      leaves = Account.includes(:book).where(id:self.leaf)
      leaves.each do |l|
        root[l.id] = l.summary(from,to)
        parent = root[l.id][:parent_id]
        while parent != id
          root[parent][:beginning] += root[l.id][:beginning]
          root[parent][:debits] += root[l.id][:debits]
          root[parent][:credits] += root[l.id][:credits]
          root[parent][:diff] += root[l.id][:diff]
          root[parent][:ending] += root[l.id][:ending]
          parent = root[parent][:parent_id] 
        end
        root[id][:beginning] += root[l.id][:beginning]
        root[id][:debits] += root[l.id][:debits]
        root[id][:credits] += root[l.id][:credits]
        root[id][:diff] += root[l.id][:diff]
        root[id][:ending] += root[l.id][:ending]
      end
      root
    end

    def children_summary(from,to)
      id = self.id
      tsum  = self.summary(from,to)
      summary = {id => tsum}
      self.children.each do |c|
        csum = c.summary(from,to)
        summary[id][:children][c.id] = csum
        summary[id][:beginning] += csum[:beginning]
        summary[id][:debits] += csum[:debits]
        summary[id][:credits] += csum[:credits]
        summary[id][:diff] += csum[:diff]
        summary[id][:ending] += csum[:ending]
      end
      summary
    end

    def summary(from,to)
      from = Ledger.set_date(from)
      to = Ledger.set_date(to)
      beginning = self.balance_on(from) * self.flipper
      splits = self.splits.joins(:entry).where(entries: {post_date:[from..to]})
      debits = splits.where(splits.arel_table[:amount].gt(0)).sum(:amount) 
      diff = splits.sum(:amount) * self.flipper
      ending = beginning + diff
      credits = debits - diff  * self.flipper
      {beginning:beginning,
        debits:debits,
        credits:credits,
        diff:diff,
        ending:ending,
        children:self.children.pluck(:id),
        parent_id:self.parent_id,
        name:self.name,
        description:self.description,
        level:self.level}
    end

    def children_ledger(date=nil,to=nil)
      date = Ledger.set_date(date)
      if to.present? # assume date = from and to = to
        @bom = date
        @eom =  Ledger.set_date(to)
      else
        @bom = date.beginning_of_month
        @eom = date.end_of_month
      end
      @kid_ids = leaf
      acct_trans =Ledger.ledger_entries(@kid_ids,@bom..@eom)
      @balance = family_balance_on(@bom)
      lines = build_ledger(acct_trans)
    end

    def account_ledger(date=nil,to=nil)
      date = Ledger.set_date(date)
      if to.present? # assume date = from and to = to
        @bom = date
        @eom =  Ledger.set_date(to)
      else
        @bom = date.beginning_of_month
        @eom = date.end_of_month
      end
      acct_trans =Ledger.ledger_entries(self.id,@bom..@eom)
      @balance = balance_on(@bom)
      build_ledger(acct_trans)
    end

    def build_ledger(acct_trans)
      bal = @balance ||= 0
      kids  = @kid_ids ||= [self.id]
      debits = credits = diff = 0
      lines = [{id: nil,date: @bom.strftime("%m/%d/%Y"),numb:nil,desc:"Beginning Balance",
          checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
      acct_trans.each do |t|
        date = t.post_date
        line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"#{t.description}",
          checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:0}
        numb_splits = t.splits.length
        t.splits.each do |s|
          details = s.details

          if kids.include?(details[:acct_id]) 
            # this is a child split line
            debits += details[:db]
            credits += details[:cr]
            diff +=  details[:amount] * self.flipper
            line[:checking][:db] += details[:db]
            line[:checking][:cr] += details[:cr]
            bal += details[:amount] * self.flipper
            line[:balance] = bal #
            line[:r] = details[:r]

          else
            line[:balance] = bal
            unless numb_splits > 2
              # this is a entry with only two splits
              line[:memo] = details[:name]
            else
              line[:memo] = "- Split Transaction -"
            end
          end
          line[:details] << details
        end
        lines << line
      end
      # p "possible endg db = #{debits} cr = #{credits} diff = #{diff}"
      summary = {id: nil,date: @eom.strftime("%m/%d/%Y"),numb:nil,desc:"Range Summary",
          checking:{db:debits,cr:credits},details:[], memo:nil,r:nil,balance:diff}
      lines << summary
    end

end
