class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :account_id
      t.date :date
      t.bigint :amount
      t.string :memo
      t.string :cleared
      t.boolean :approved
      t.string :flag_color
      t.string :payee_id
      t.string :category_id
      t.string :transfer_account_id
      t.string :transfer_transaction_id
      t.string :matched_transaction_id
      t.string :import_id
      t.boolean :deleted

      t.timestamps
    end
    add_index :transactions, :ynab_id, unique: true
    add_index :transactions, :plan_id
    add_index :transactions, :account_id
    add_index :transactions, :payee_id
    add_index :transactions, :category_id
  end
end
