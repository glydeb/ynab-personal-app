class CategoryGroup < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  has_many :categories, primary_key: :ynab_id, foreign_key: :category_group_id, dependent: :destroy
end
