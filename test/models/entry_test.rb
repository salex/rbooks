require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  setup do
    @book = books(:b1)
    @entry = @book.entries.create(numb: '1003',post_date: '2020-10-28',description: 'Test entry')
    @entry.splits.create(memo:'split a2', amount:500, account_id:accounts(:a2).id)
    @entry.splits.create(memo:'split a6', amount:-500, account_id:accounts(:a6).id)
  end

  test "entry setup" do
    # puts @entry.inspect
    # puts @entry.splits.inspect
  end


  test "balanced" do
    sum = @entry.splits.sum(:amount)
    assert_equal(0,sum,'splits sum is zero')
    @entry.splits[0].amount = 700
    @entry.splits[0].save
    # puts @entry.splits[0].inspect
    sum = @entry.splits.sum(:amount)
    assert_not_equal(0,sum,'they be  unbalanced')


  end
end
