class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :name
      t.string :account_type
      t.boolean :on_budget
      t.boolean :closed
      t.bigint :balance
      t.bigint :cleared_balance
      t.bigint :uncleared_balance
      t.string :transfer_payee_id
      t.boolean :deleted

      t.timestamps
    end
    add_index :accounts, :ynab_id, unique: true
    add_index :accounts, :plan_id
  end
end
