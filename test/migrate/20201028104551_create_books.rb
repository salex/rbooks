class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string :name
      t.string :root
      t.string :assets
      t.string :equity
      t.string :liabilities
      t.string :income
      t.string :expenses
      t.string :checking
      t.string :savings
      t.text :settings

      t.timestamps
    end
  end
end
