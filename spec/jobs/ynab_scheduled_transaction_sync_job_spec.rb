require 'rails_helper'

RSpec.describe YnabScheduledTransactionSyncJob, type: :job do
  describe '#perform' do
    let(:plan_id) { 'fake-plan-id' }
    let(:mock_client) { instance_double(YNAB::API) }
    let(:mock_api) { instance_double(YNAB::ScheduledTransactionsApi) }
    let(:mock_service) { instance_double(Ynab::ClientService, client: mock_client) }

    before do
      allow(Ynab::ClientService).to receive(:new).and_return(mock_service)
      allow(mock_client).to receive(:scheduled_transactions).and_return(mock_api)
    end

    context 'when no previous server knowledge exists' do
      it 'fetches all records, saves them, and saves the new server knowledge within a transaction' do
        mock_response = double('response', data: double('data', server_knowledge: 100, scheduled_transactions: []))
        expect(mock_api).to receive(:get_scheduled_transactions).with(plan_id).and_return(mock_response)

        expect(ActiveRecord::Base).to receive(:transaction).and_call_original

        described_class.new.perform(plan_id)

        knowledge = ServerKnowledge.find_by(plan_id: plan_id, topic: 'scheduled_transactions')
        expect(knowledge.knowledge).to eq(100)
      end
    end

    context 'when previous server knowledge exists' do
      before do
        create(:server_knowledge, plan_id: plan_id, topic: 'scheduled_transactions', knowledge: 50)
      end

      it 'makes a delta request passing the previous server knowledge' do
        mock_response = double('response', data: double('data', server_knowledge: 105, scheduled_transactions: []))
        expect(mock_api).to receive(:get_scheduled_transactions)
          .with(plan_id, last_knowledge_of_server: 50)
          .and_return(mock_response)

        described_class.new.perform(plan_id)

        knowledge = ServerKnowledge.find_by(plan_id: plan_id, topic: 'scheduled_transactions')
        expect(knowledge.knowledge).to eq(105)
      end
    end

    context 'when an error occurs' do
      it 'logs the error and re-raises it, aborting the transaction' do
        expect(mock_api).to receive(:get_scheduled_transactions).and_raise(StandardError.new('API Failure'))
        expect(Rails.logger).to receive(:error).with(/YnabScheduledTransactionSyncJob failed for plan_id fake-plan-id: API Failure/)
        expect(Rails.logger).to receive(:error).with(anything) # for backtrace

        expect {
          described_class.new.perform(plan_id)
        }.to raise_error(StandardError, 'API Failure')
      end
    end

    context 'processing delta payloads' do
      let(:response_data) { double('data', server_knowledge: 100, scheduled_transactions: items) }
      let(:mock_response) { double('response', data: response_data) }

      before do
        allow(mock_api).to receive(:get_scheduled_transactions).and_return(mock_response)
      end

      context 'with a deleted record' do
        let(:items) do
          [ double('item', id: 'record-2', deleted: true) ]
        end

        before do
          create(:scheduled_transaction, ynab_id: 'record-2')
        end

        it 'destroys the local record' do
          expect {
            described_class.new.perform(plan_id)
          }.to change(ScheduledTransaction, :count).by(-1)

          expect(ScheduledTransaction.find_by(ynab_id: 'record-2')).to be_nil
        end
      end
    end
  end
end
