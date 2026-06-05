class YnabTransaction < ApplicationRecord
  belongs_to :plan, primary_key: :ynab_id, foreign_key: :plan_id, optional: true
  belongs_to :account, primary_key: :ynab_id, foreign_key: :account_id, optional: true
  belongs_to :payee, primary_key: :ynab_id, foreign_key: :payee_id, optional: true
  belongs_to :category, primary_key: :ynab_id, foreign_key: :category_id, optional: true
  has_many :subtransactions, primary_key: :ynab_id, foreign_key: :transaction_id, dependent: :destroy
  has_many :rejected_categories, primary_key: :ynab_id, foreign_key: :ynab_transaction_id, dependent: :destroy
  has_one :transaction_metadata, primary_key: :ynab_id, foreign_key: :ynab_transaction_id, dependent: :destroy

  scope :unapproved, -> { where(approved: false, deleted: [false, nil]) }
  scope :unmatched, -> {
    left_outer_joins(:transaction_metadata)
    .where(matched_transaction_id: nil)
    .where("transaction_metadata.marked_as_matched IS NOT TRUE")
  }
  scope :uncategorized_unapproved, -> { unapproved.unmatched.where(category_id: nil) }
  scope :pre_categorized_unapproved, -> { unapproved.unmatched.where.not(category_id: nil) }
end
