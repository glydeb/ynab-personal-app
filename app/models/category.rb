class Category < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  belongs_to :category_group, primary_key: :ynab_id, foreign_key: :category_group_id, optional: true
  has_many :ynab_transactions, primary_key: :ynab_id, foreign_key: :category_id, dependent: :nullify
  has_many :rejected_categories, primary_key: :ynab_id, foreign_key: :category_id, dependent: :destroy
end
