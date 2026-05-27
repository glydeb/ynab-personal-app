class CreateRejectedCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :rejected_categories do |t|
      t.string :ynab_transaction_id
      t.string :category_id

      t.timestamps
    end
    add_index :rejected_categories, :ynab_transaction_id
    add_index :rejected_categories, :category_id
  end
end
