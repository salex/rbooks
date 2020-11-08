class ReCreateStructure < ActiveRecord::Migration[6.0]
  def change
    create_table "accounts", force: :cascade do |t|
      t.string "uuid"
      t.bigint "book_id", null: false
      t.string "name"
      t.string "account_type"
      t.string "code"
      t.string "description"
      t.boolean "placeholder", default: false
      t.boolean "contra", default: false
      t.integer "parent_id"
      t.integer "level"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["book_id"], name: "index_accounts_on_book_id"
    end

    create_table "bank_statements", force: :cascade do |t|
      t.bigint "book_id", null: false
      t.date "statement_date"
      t.integer "beginning_balance"
      t.integer "ending_balance"
      t.text "ofx_data"
      t.text "hash_data"
      t.date "reconciled_date"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["book_id"], name: "index_bank_statements_on_book_id"
    end

    create_table "books", force: :cascade do |t|
      t.string "name"
      t.string "root"
      t.string "assets"
      t.string "equity"
      t.string "liabilities"
      t.string "income"
      t.string "expenses"
      t.string "checking"
      t.string "savings"
      t.text "settings"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "deposits", force: :cascade do |t|
      t.date "date"
      t.float "sales_revenue", default: 0.0
      t.float "other_revenue", default: 0.0
      t.float "cash_sales", default: 0.0
      t.float "credit_sales", default: 0.0
      t.float "tips_paid", default: 0.0
      t.float "sales_deposit", default: 0.0
      t.float "other_deposit", default: 0.0
      t.float "total_deposit", default: 0.0
      t.float "cash_out", default: 0.0
    end

    create_table "entries", force: :cascade do |t|
      t.string "numb"
      t.date "post_date"
      t.string "description"
      t.string "fit_id"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "book_id", null: false
      t.integer "lock_version"
      t.index ["book_id"], name: "index_entries_on_book_id"
      t.index ["description"], name: "index_entries_on_description"
      t.index ["post_date"], name: "index_entries_on_post_date"
    end

    create_table "revenues", force: :cascade do |t|
      t.bigint "deposit_id", null: false
      t.string "type"
      t.string "item"
      t.integer "quanity"
      t.float "amount"
      t.string "remarks"
      t.index ["deposit_id"], name: "index_revenues_on_deposit_id"
    end

    create_table "sales_items", force: :cascade do |t|
      t.string "name"
      t.string "type"
      t.float "price"
      t.float "cost"
      t.string "department"
      t.float "markup"
      t.integer "quanity"
      t.integer "alert"
      t.integer "size"
      t.integer "cases"
      t.integer "bottles"
      t.integer "bottles_1"
      t.integer "bottles_2"
      t.integer "percent"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "status"
    end

    create_table "splits", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.bigint "entry_id", null: false
      t.string "memo"
      t.string "action"
      t.string "reconcile_state"
      t.date "reconcile_date"
      t.integer "amount"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "lock_version"
      t.index ["account_id"], name: "index_splits_on_account_id"
      t.index ["entry_id"], name: "index_splits_on_entry_id"
    end

    create_table "stashes", force: :cascade do |t|
      t.string "stashable_type", null: false
      t.bigint "stashable_id", null: false
      t.string "type"
      t.date "date"
      t.text "hash_data"
      t.text "text_data"
      t.text "slim"
      t.text "yaml"
      t.text "csv"
      t.date "date_data"
      t.string "status"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["stashable_type", "stashable_id"], name: "index_stashes_on_stashable_type_and_stashable_id"
      t.index ["type"], name: "index_stashes_on_type"
    end

    create_table "users", force: :cascade do |t|
      t.string "email"
      t.string "username"
      t.string "full_name"
      t.string "roles"
      t.string "password_digest"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.integer "default_book"
    end

    add_foreign_key "accounts", "books"
    add_foreign_key "bank_statements", "books"
    add_foreign_key "entries", "books"
    add_foreign_key "revenues", "deposits"
    add_foreign_key "splits", "accounts"
    add_foreign_key "splits", "entries"
  end
end
