class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :category_group_id
      t.string :name
      t.boolean :hidden
      t.bigint :budgeted
      t.bigint :activity
      t.bigint :balance
      t.boolean :deleted

      t.timestamps
    end
    add_index :categories, :ynab_id, unique: true
    add_index :categories, :plan_id
    add_index :categories, :category_group_id
  end
end
