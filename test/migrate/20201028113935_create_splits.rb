class CreateSplits < ActiveRecord::Migration[6.0]
  def change
    create_table :splits do |t|
      t.references :account, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.string :memo
      t.string :action
      t.string :reconcile_state
      t.date :reconcile_date
      t.integer :amount
      t.integer :lock_version

      t.timestamps
    end
  end
end
