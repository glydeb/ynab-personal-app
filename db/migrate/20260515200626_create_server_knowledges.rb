class CreateServerKnowledges < ActiveRecord::Migration[8.1]
  def change
    create_table :server_knowledges do |t|
      t.string :topic
      t.string :plan_id
      t.bigint :knowledge

      t.timestamps
    end
    add_index :server_knowledges, :plan_id
  end
end
