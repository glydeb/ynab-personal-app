class CreateCategoryGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :category_groups do |t|
      t.string :ynab_id
      t.string :plan_id
      t.string :name
      t.boolean :hidden
      t.boolean :deleted

      t.timestamps
    end
    add_index :category_groups, :ynab_id, unique: true
    add_index :category_groups, :plan_id
  end
end
