require 'rails_helper'

RSpec.describe YnabPlanSyncJob, type: :job do
  describe '#perform' do
    let(:mock_client) { instance_double(YNAB::API) }
    let(:mock_plans_api) { instance_double(YNAB::PlansApi) }
    let(:mock_service) { instance_double(Ynab::ClientService, client: mock_client) }

    before do
      allow(Ynab::ClientService).to receive(:new).and_return(mock_service)
      allow(mock_client).to receive(:plans).and_return(mock_plans_api)
    end

    it 'fetches all plans and saves them within a transaction' do
      plans = [
        double('plan', id: 'plan-1', name: 'My Plan', last_modified_on: '2023-01-01T00:00:00Z')
      ]
      mock_response = double('response', data: double('data', plans: plans))
      expect(mock_plans_api).to receive(:get_plans).and_return(mock_response)

      expect(ActiveRecord::Base).to receive(:transaction).and_call_original

      expect {
        described_class.new.perform
      }.to change(Plan, :count).by(1)

      plan = Plan.find_by(ynab_id: 'plan-1')
      expect(plan.name).to eq('My Plan')
    end

    context 'when an error occurs' do
      it 'logs the error and re-raises it, aborting the transaction' do
        expect(mock_plans_api).to receive(:get_plans).and_raise(StandardError.new('API Failure'))
        expect(Rails.logger).to receive(:error).with(/YnabPlanSyncJob failed: API Failure/)
        expect(Rails.logger).to receive(:error).with(anything) # for backtrace

        expect {
          described_class.new.perform
        }.to raise_error(StandardError, 'API Failure')
      end
    end
  end
end
