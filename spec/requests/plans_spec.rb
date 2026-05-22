require 'rails_helper'

RSpec.describe 'Plans', type: :request do
  let!(:plan) { create(:plan) }

  describe 'GET /plans' do
    it 'returns http success' do
      get plans_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /plans/:id' do
    it 'returns http success' do
      get plan_path(plan)
      expect(response).to have_http_status(:success)
    end
  end
end
