class Pdf::Register < Prawn::Document
  attr_accessor :response, :date

  def initialize(date,account=nil,to=nil)
    super( top_margin: 35)
    self.date = Ledger.set_date(date)
    if to.present?
      to = Ledger.set_date(to)
    else
      self.date = @date.beginning_of_month
    end
    self.response = {rows:nil}
    if account.nil?
      account = Current.book.checking_acct
      @response[:rows] = account.children_ledger(@date)
    else
      # account = Current.book.accounts.find(account)
      if account.has_children?
        @response[:rows] = account.children_ledger(@date,to)
      else
        @response[:rows] = account.account_ledger(@date,to)
      end
    end
    @account = account
    make_pdf
    number_pages "#{Date.today}   -   Page <page> of <total>", { :start_count_at => 0, :page_filter => :all, :at => [bounds.right - 100, 0], :align => :right, :size => 6 }
  end

  def header
    arr = ["Date", "Numb","Description","Account","R","Debits","Credits", "Balance"]
  end

  # def balance_row
  #   [{content:'',colspan: 2},"Beginning Balance",nil,nil,nil,nil,{content: money(@response[:balances][:checking][:bbalance]),align: :right}]
  # end

  def make_pdf
    font_size 7
    build_table
    draw_table
  end

  def build_table
    @rows = [header]
    @response[:rows].each do |row|
      arr =  [row[:date],row[:numb],row[:desc],row[:memo],row[:r]]
      arr << (row[:checking][:db].zero? ? nil : {content: money(row[:checking][:db]), align: :right})
      arr << (row[:checking][:cr].zero? ? nil : {content: money(row[:checking][:cr]), align: :right})
      arr << (row[:balance].zero? ? nil : {content: money(row[:balance]), align: :right})
      @rows << arr
    end
  end

  def draw_table
    text " #{@account.name} Register - #{@date}", style: :bold, align: :center
    move_down(2)
    e = make_table @rows,row_colors: ["F8F8F8", "FFFFFF"],:cell_style => {:padding => [1, 2, 2, 1],border_color:"E0E0E0"}, 
      :column_widths => [40, 28, 170,160,10,40,40,40,40], header:true do
      row(0).font_style = :bold
    end
    e.draw
  end

 def money(int)
   Ledger.money(int)
 end

end
