class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :ynab_id
      t.string :name
      t.datetime :last_modified_on

      t.timestamps
    end
    add_index :plans, :ynab_id, unique: true
  end
end
