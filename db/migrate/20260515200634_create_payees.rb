class CreatePayees < ActiveRecord::Migration[8.1]
  def change
    create_table :payees do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :name
      t.string :transfer_account_id
      t.boolean :deleted

      t.timestamps
    end
    add_index :payees, :ynab_id, unique: true
    add_index :payees, :plan_id
  end
end
