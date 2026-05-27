class YnabTransaction < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  belongs_to :account, primary_key: :ynab_id, foreign_key: :account_id, optional: true
  belongs_to :payee, primary_key: :ynab_id, foreign_key: :payee_id, optional: true
  belongs_to :category, primary_key: :ynab_id, foreign_key: :category_id, optional: true
  has_many :subtransactions, primary_key: :ynab_id, foreign_key: :transaction_id, dependent: :destroy
  has_many :rejected_categories, primary_key: :ynab_id, foreign_key: :ynab_transaction_id, dependent: :destroy

  scope :unapproved, -> { where(approved: false, deleted: [false, nil]) }
  scope :uncategorized_unapproved, -> { unapproved.where(category_id: nil) }
  scope :pre_categorized_unapproved, -> { unapproved.where.not(category_id: nil) }
end
