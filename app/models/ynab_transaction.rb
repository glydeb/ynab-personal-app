class YnabTransaction < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  belongs_to :account, primary_key: :ynab_id, foreign_key: :account_id, optional: true
  belongs_to :payee, primary_key: :ynab_id, foreign_key: :payee_id, optional: true
  belongs_to :category, primary_key: :ynab_id, foreign_key: :category_id, optional: true
  has_many :subtransactions, primary_key: :ynab_id, foreign_key: :transaction_id, dependent: :destroy
end
