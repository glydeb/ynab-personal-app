require 'rails_helper'

RSpec.describe YnabTransactionSyncJob, type: :job do
  describe '#perform' do
    let(:plan_id) { 'fake-plan-id' }
    let(:mock_client) { instance_double(YNAB::API) }
    let(:mock_transactions_api) { instance_double(YNAB::TransactionsApi) }
    let(:mock_service) { instance_double(Ynab::ClientService, client: mock_client) }

    before do
      allow(Ynab::ClientService).to receive(:new).and_return(mock_service)
      allow(mock_client).to receive(:transactions).and_return(mock_transactions_api)
    end

    context 'when no previous server knowledge exists' do
      it 'fetches all transactions, saves them, and saves the new server knowledge within a transaction' do
        mock_response = double('response', data: double('data', server_knowledge: 100, transactions: []))
        expect(mock_transactions_api).to receive(:get_transactions).with(plan_id).and_return(mock_response)

        expect(ActiveRecord::Base).to receive(:transaction).and_call_original

        described_class.new.perform(plan_id)

        knowledge = ServerKnowledge.find_by(plan_id: plan_id, topic: 'transactions')
        expect(knowledge.knowledge).to eq(100)
      end
    end

    context 'when previous server knowledge exists' do
      before do
        create(:server_knowledge, plan_id: plan_id, topic: 'transactions', knowledge: 50)
      end

      it 'makes a delta request passing the previous server knowledge' do
        mock_response = double('response', data: double('data', server_knowledge: 105, transactions: []))
        expect(mock_transactions_api).to receive(:get_transactions)
          .with(plan_id, last_knowledge_of_server: 50)
          .and_return(mock_response)

        described_class.new.perform(plan_id)

        knowledge = ServerKnowledge.find_by(plan_id: plan_id, topic: 'transactions')
        expect(knowledge.knowledge).to eq(105)
      end
    end

    context 'when an error occurs' do
      it 'logs the error and re-raises it, aborting the transaction' do
        expect(mock_transactions_api).to receive(:get_transactions).and_raise(StandardError.new('API Failure'))
        expect(Rails.logger).to receive(:error).with(/YnabTransactionSyncJob failed for plan_id fake-plan-id: API Failure/)
        expect(Rails.logger).to receive(:error).with(anything) # for backtrace

        expect {
          described_class.new.perform(plan_id)
        }.to raise_error(StandardError, 'API Failure')
      end
    end
  end
end
