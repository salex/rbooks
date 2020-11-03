class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :uuid
      t.references :book, null: false, foreign_key: true
      t.string :name
      t.string :account_type
      t.string :code
      t.string :description
      t.boolean :placeholder
      t.boolean :contra
      t.integer :parent_id
      t.integer :level

      t.timestamps
    end
  end
end
