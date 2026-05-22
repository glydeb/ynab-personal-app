class Plan < ApplicationRecord
  has_many :server_knowledges, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :accounts, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :payees, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :category_groups, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :categories, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :ynab_transactions, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
  has_many :scheduled_transactions, primary_key: :ynab_id, foreign_key: :plan_id, dependent: :destroy
end
