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

      # Test sorting logic safely with secondary_sort
      get plan_unapproved_transactions_path(plan, sort: 'payee', direction: 'asc', secondary_sort: 'amount')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /plans/:plan_id/unapproved_transactions/sync' do
    it 'performs the YnabTransactionSyncJob synchronously and redirects' do
      expect(YnabTransactionSyncJob).to receive(:perform_now).with(plan.id)
      
      post sync_plan_unapproved_transactions_path(plan)
      
      expect(response).to redirect_to(plan_unapproved_transactions_path(plan))
      expect(flash[:notice]).to eq("Transactions successfully synchronized with YNAB.")
    end
  end

  describe 'POST /plans/:plan_id/unapproved_transactions/approve' do
    let(:transactions_to_approve) { [create(:ynab_transaction, plan: plan, approved: false, category: category)] }

    it 'calls BulkUpdateService and redirects with success' do
      service_mock = instance_double(Ynab::BulkUpdateService)
      allow(Ynab::BulkUpdateService).to receive(:new).with(plan).and_return(service_mock)
      expect(service_mock).to receive(:approve_transactions).and_return(true)

      post approve_plan_unapproved_transactions_path(plan), params: { transaction_ids: transactions_to_approve.map(&:id) }
      
      expect(response).to redirect_to(plan_unapproved_transactions_path(plan))
      expect(flash[:notice]).to match(/Successfully approved/)
    end

    it 'redirects with error if no transactions selected' do
      post approve_plan_unapproved_transactions_path(plan)
      
      expect(response).to redirect_to(plan_unapproved_transactions_path(plan))
      expect(flash[:alert]).to eq("No transactions were selected.")
    end
  end
end
