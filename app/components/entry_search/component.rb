# frozen_string_literal: true
module EntrySearch

  class Component < ViewComponent::Base
    def initialize(entries:)
      @entries = entries
    end

    def to_money(pennies,unit="")
      pennies = 0 if pennies.blank?
      dollars = pennies / 100
      cents = (pennies % 100) / 100.0
      amt = dollars + cents
      number_to_currency(amt,unit:unit)
    end

  end
end