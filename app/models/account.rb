class Account < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  has_many :ynab_transactions, primary_key: :ynab_id, foreign_key: :account_id, dependent: :destroy
end
