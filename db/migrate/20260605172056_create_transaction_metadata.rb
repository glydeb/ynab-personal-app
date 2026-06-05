class CreateTransactionMetadata < ActiveRecord::Migration[8.1]
  def change
    create_table :transaction_metadata do |t|
      t.string :ynab_transaction_id, index: true
      t.boolean :marked_as_matched, default: false
      t.timestamps
    end
  end
end
