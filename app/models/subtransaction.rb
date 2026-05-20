class Subtransaction < ApplicationRecord
  belongs_to :ynab_transaction, primary_key: :ynab_id, foreign_key: :transaction_id, optional: true
  belongs_to :payee, primary_key: :ynab_id, foreign_key: :payee_id, optional: true
  belongs_to :category, primary_key: :ynab_id, foreign_key: :category_id, optional: true
end
