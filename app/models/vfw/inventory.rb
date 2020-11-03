class Inventory < Stash
  require 'csv'

  # the below is a one time create simple inventory if you are only going to have one
  after_initialize :set_stashable

  def set_stashable
    if self.new_record?
      self.stashable_id = 1
      self.stashable_type = "Stash"
      seed
    else
      self.inventory = hash_data
      self.beer = inventory['beer']
      self.liquor = inventory['liquor']
      self.qoh = CSV.parse(csv)
      qoh.delete_at(0)
    end
  end

  attribute :inventory
  attribute :beer
  attribute :liquor
  attribute :qoh

  def seed
    beer_path = Rails.root.join('yaml/inventory/beer.yaml')
    liquor_path = Rails.root.join('yaml/inventory/liquor.yaml')
    qoh_path = Rails.root.join('yaml/inventory/qoh.csv')
    self.csv = File.read(qoh_path)
    self.inventory = {}.with_indifferent_access
    beer =  YAML.load_file(beer_path)
    liquor = YAML.load_file(liquor_path)
    inventory[:beer] = beer
    inventory[:liquor] = liquor
    self.beer = beer
    self.liquor = liquor
    self.hash_data = inventory
    self.qoh = CSV.parse(csv)
    qoh.delete_at(0)
    self.save
    
  end

  def get_qoh
    # qoh_path = Rails.root.join('yaml/inventory/qoh.csv')
    # qoh = CSV.parse(File.read(qoh_path))
    # qoh.delete_at(0)
    @beer_qoh = []
    @liquor_qoh = []
    revenue = ["Liqueur","Rum & Tequila","Whiskey","Gin & Vodka"]
    qoh.each do |item|
      @liquor_qoh << item if revenue.include?(item[1])
      @beer_qoh << item if item[1] == 'Beer'
    end
  end

  def update_liquor(params)
    liquor = {}
    params['deposit']["liquor"].each do |h|
      liquor[h[0]] = h[1]
    end
    inventory[:liquor] =liquor
    self.save
  end

  def update_beer(params)
    beer = {}
    params['deposit']["beer"].each do |h|
      beer[h[0]] = h[1]
    end
    inventory[:beer] = beer
    self.save
  end



end