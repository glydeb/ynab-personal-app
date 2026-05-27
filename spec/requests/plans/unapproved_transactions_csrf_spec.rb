require 'rails_helper'
require 'nokogiri'

RSpec.describe 'CSRF Protection for Unapproved Transactions', type: :request do
  let(:plan) { create(:plan) }
  let(:category) { create(:category, plan: plan) }
  let!(:transaction) { create(:ynab_transaction, plan: plan, approved: false, category: category) }

  before do
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  it 'submits successfully using the correct form token' do
    # Fetch the page to get the authenticity token from the form
    get plan_unapproved_transactions_path(plan)
    
    html = Nokogiri::HTML(response.body)
    
    form = html.at('form#approve-form')
    token = form.at('input[name="authenticity_token"]')['value']
    action = form['action']

    # Mock the service
    service_mock = instance_double(Ynab::BulkUpdateService)
    allow(Ynab::BulkUpdateService).to receive(:new).and_return(service_mock)
    allow(service_mock).to receive(:clear_categories).and_return(true)

    # Submit to the form action URL with the token and commit=reject
    post action, params: { 
      transaction_ids: [transaction.id], 
      commit: 'reject',
      authenticity_token: token 
    }

    # Should succeed without raising ActionController::InvalidAuthenticityToken
    expect(response).to redirect_to(plan_unapproved_transactions_path(plan))
    expect(flash[:notice]).to match(/Successfully cleared categories/)
  end
end
