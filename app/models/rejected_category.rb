class RejectedCategory < ApplicationRecord
  belongs_to :ynab_transaction, foreign_key: :ynab_transaction_id, primary_key: :ynab_id
  belongs_to :category, foreign_key: :category_id, primary_key: :ynab_id
end
