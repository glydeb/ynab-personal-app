class CreateScheduledTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :scheduled_transactions do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :account_id
      t.string :payee_id
      t.string :category_id
      t.string :transfer_account_id
      t.bigint :amount
      t.date :date
      t.string :frequency
      t.string :memo
      t.string :flag_color
      t.boolean :deleted

      t.timestamps
    end
    add_index :scheduled_transactions, :ynab_id, unique: true
    add_index :scheduled_transactions, :plan_id
    add_index :scheduled_transactions, :account_id
  end
end
