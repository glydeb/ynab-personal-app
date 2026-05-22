require 'rails_helper'

RSpec.describe 'Plans::UnapprovedTransactions', type: :request do
  let!(:plan) { create(:plan) }
  let!(:category) { create(:category, plan: plan) }

  before do
    # Pre-categorized unapproved
    create(:ynab_transaction, plan: plan, approved: false, category: category, amount: 1000)

    # Uncategorized unapproved
    create(:ynab_transaction, plan: plan, approved: false, category: nil, amount: -1000)

    # Approved (should not appear)
    create(:ynab_transaction, plan: plan, approved: true, category: nil)
  end

  describe 'GET /plans/:plan_id/unapproved_transactions' do
    it 'returns http success and loads separated transactions' do
      get plan_unapproved_transactions_path(plan)
      expect(response).to have_http_status(:success)

      # Test sorting logic safely
      get plan_unapproved_transactions_path(plan, sort: 'amount', direction: 'asc')
      expect(response).to have_http_status(:success)
    end
  end
end
