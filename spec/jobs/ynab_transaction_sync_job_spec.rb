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

    context 'processing delta payloads' do
      let(:response_data) { double('data', server_knowledge: 100, transactions: transactions) }
      let(:mock_response) { double('response', data: response_data) }

      before do
        allow(mock_transactions_api).to receive(:get_transactions).and_return(mock_response)
      end

      context 'with a new or updated transaction' do
        let(:transactions) do
          [
            double('transaction',
                   id: 'tx-1',
                   deleted: false,
                   account_id: 'acc-1',
                   date: '2023-01-01',
                   amount: 1000,
                   memo: 'Groceries',
                   cleared: 'cleared',
                   approved: true,
                   flag_color: 'red',
                   payee_id: 'pay-1',
                   category_id: 'cat-1',
                   transfer_account_id: nil,
                   transfer_transaction_id: nil,
                   matched_transaction_id: nil,
                   import_id: nil,
                   subtransactions: [])
          ]
        end

        it 'upserts the transaction with correct attributes' do
          expect {
            described_class.new.perform(plan_id)
          }.to change(YnabTransaction, :count).by(1)

          tx = YnabTransaction.find_by(ynab_id: 'tx-1')
          expect(tx.memo).to eq('Groceries')
          expect(tx.amount).to eq(1000)
          expect(tx.account_id).to eq('acc-1')
          expect(tx.date.to_s).to eq('2023-01-01')
        end
      end

      context 'with a deleted transaction' do
        let(:transactions) do
          [ double('transaction', id: 'tx-2', deleted: true, subtransactions: []) ]
        end

        before do
          create(:ynab_transaction, ynab_id: 'tx-2', plan_id: plan_id)
        end

        it 'destroys the local transaction' do
          expect {
            described_class.new.perform(plan_id)
          }.to change(YnabTransaction, :count).by(-1)

          expect(YnabTransaction.find_by(ynab_id: 'tx-2')).to be_nil
        end
      end

      context 'with subtransactions' do
        let(:transactions) do
          [
            double('transaction',
                   id: 'tx-3',
                   deleted: false,
                   account_id: 'acc-1',
                   date: '2023-01-01',
                   amount: 1000,
                   memo: 'Split',
                   cleared: 'cleared',
                   approved: true,
                   flag_color: nil,
                   payee_id: 'pay-1',
                   category_id: nil,
                   transfer_account_id: nil,
                   transfer_transaction_id: nil,
                   matched_transaction_id: nil,
                   import_id: nil,
                   subtransactions: subtransactions)
          ]
        end

        context 'when subtransaction is new or updated' do
          let(:subtransactions) do
            [
              double('subtransaction',
                     id: 'sub-1',
                     deleted: false,
                     amount: 500,
                     memo: 'Part 1',
                     payee_id: 'pay-1',
                     category_id: 'cat-2',
                     transfer_account_id: nil,
                     transfer_transaction_id: nil)
            ]
          end

          it 'upserts the subtransaction' do
            expect {
              described_class.new.perform(plan_id)
            }.to change(Subtransaction, :count).by(1)

            stx = Subtransaction.find_by(ynab_id: 'sub-1')
            expect(stx.memo).to eq('Part 1')
            expect(stx.amount).to eq(500)
            expect(stx.transaction_id).to eq('tx-3')
          end
        end

        context 'when subtransaction is deleted' do
          let(:subtransactions) do
            [
              double('subtransaction', id: 'sub-2', deleted: true)
            ]
          end

          before do
            create(:subtransaction, ynab_id: 'sub-2')
          end

          it 'destroys the local subtransaction' do
            expect {
              described_class.new.perform(plan_id)
            }.to change(Subtransaction, :count).by(-1)

            expect(Subtransaction.find_by(ynab_id: 'sub-2')).to be_nil
          end
        end
      end
    end
  end
end
