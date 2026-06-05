class TransactionMetadata < ApplicationRecord
  belongs_to :ynab_transaction, primary_key: :ynab_id, foreign_key: :ynab_transaction_id, optional: true
end
