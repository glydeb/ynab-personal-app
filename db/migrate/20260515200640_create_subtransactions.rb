class CreateSubtransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :subtransactions do |t|
      t.string :ynab_id
      t.string :transaction_id
      t.bigint :amount
      t.string :memo
      t.string :payee_id
      t.string :category_id
      t.string :transfer_account_id
      t.string :transfer_transaction_id
      t.boolean :deleted

      t.timestamps
    end
    add_index :subtransactions, :ynab_id, unique: true
    add_index :subtransactions, :transaction_id
  end
end
