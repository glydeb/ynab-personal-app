# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_05_172056) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_type"
    t.bigint "balance"
    t.bigint "cleared_balance"
    t.boolean "closed"
    t.datetime "created_at", null: false
    t.boolean "deleted"
    t.string "name"
    t.boolean "on_budget"
    t.string "plan_id"
    t.string "transfer_payee_id"
    t.bigint "uncleared_balance"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["plan_id"], name: "index_accounts_on_plan_id"
    t.index ["ynab_id"], name: "index_accounts_on_ynab_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "activity"
    t.bigint "balance"
    t.bigint "budgeted"
    t.string "category_group_id"
    t.datetime "created_at", null: false
    t.boolean "deleted"
    t.boolean "hidden"
    t.string "name"
    t.string "plan_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["category_group_id"], name: "index_categories_on_category_group_id"
    t.index ["plan_id"], name: "index_categories_on_plan_id"
    t.index ["ynab_id"], name: "index_categories_on_ynab_id", unique: true
  end

  create_table "category_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "deleted"
    t.boolean "hidden"
    t.string "name"
    t.string "plan_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["plan_id"], name: "index_category_groups_on_plan_id"
    t.index ["ynab_id"], name: "index_category_groups_on_ynab_id", unique: true
  end

  create_table "payees", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "deleted"
    t.string "name"
    t.string "plan_id"
    t.string "transfer_account_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["plan_id"], name: "index_payees_on_plan_id"
    t.index ["ynab_id"], name: "index_payees_on_ynab_id", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_modified_on"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["ynab_id"], name: "index_plans_on_ynab_id", unique: true
  end

  create_table "rejected_categories", force: :cascade do |t|
    t.string "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ynab_transaction_id"
    t.index ["category_id"], name: "index_rejected_categories_on_category_id"
    t.index ["ynab_transaction_id"], name: "index_rejected_categories_on_ynab_transaction_id"
  end

  create_table "scheduled_transactions", force: :cascade do |t|
    t.string "account_id"
    t.bigint "amount"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.date "date"
    t.boolean "deleted"
    t.string "flag_color"
    t.string "frequency"
    t.string "memo"
    t.string "payee_id"
    t.string "plan_id"
    t.string "transfer_account_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["account_id"], name: "index_scheduled_transactions_on_account_id"
    t.index ["plan_id"], name: "index_scheduled_transactions_on_plan_id"
    t.index ["ynab_id"], name: "index_scheduled_transactions_on_ynab_id", unique: true
  end

  create_table "server_knowledges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "knowledge"
    t.string "plan_id"
    t.string "topic"
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_server_knowledges_on_plan_id"
  end

  create_table "subtransactions", force: :cascade do |t|
    t.bigint "amount"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.boolean "deleted"
    t.string "memo"
    t.string "payee_id"
    t.string "transaction_id"
    t.string "transfer_account_id"
    t.string "transfer_transaction_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["transaction_id"], name: "index_subtransactions_on_transaction_id"
    t.index ["ynab_id"], name: "index_subtransactions_on_ynab_id", unique: true
  end

  create_table "transaction_metadata", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "marked_as_matched", default: false
    t.datetime "updated_at", null: false
    t.string "ynab_transaction_id"
    t.index ["ynab_transaction_id"], name: "index_transaction_metadata_on_ynab_transaction_id"
  end

  create_table "ynab_transactions", force: :cascade do |t|
    t.string "account_id"
    t.bigint "amount"
    t.boolean "approved"
    t.string "category_id"
    t.string "cleared"
    t.datetime "created_at", null: false
    t.date "date"
    t.boolean "deleted"
    t.string "flag_color"
    t.string "import_id"
    t.string "matched_transaction_id"
    t.string "memo"
    t.string "payee_id"
    t.string "plan_id"
    t.string "transfer_account_id"
    t.string "transfer_transaction_id"
    t.datetime "updated_at", null: false
    t.string "ynab_id"
    t.index ["account_id"], name: "index_ynab_transactions_on_account_id"
    t.index ["category_id"], name: "index_ynab_transactions_on_category_id"
    t.index ["payee_id"], name: "index_ynab_transactions_on_payee_id"
    t.index ["plan_id"], name: "index_ynab_transactions_on_plan_id"
    t.index ["ynab_id"], name: "index_ynab_transactions_on_ynab_id", unique: true
  end
end
