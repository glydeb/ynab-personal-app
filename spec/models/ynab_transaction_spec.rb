require 'rails_helper'

RSpec.describe YnabTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:plan).with_primary_key(:ynab_id).with_foreign_key(:plan_id).optional }
    it { should belong_to(:account).with_primary_key(:ynab_id).with_foreign_key(:account_id).optional }
    it { should belong_to(:payee).with_primary_key(:ynab_id).with_foreign_key(:payee_id).optional }
    it { should belong_to(:category).with_primary_key(:ynab_id).with_foreign_key(:category_id).optional }
    it { should have_many(:subtransactions).with_primary_key(:ynab_id).with_foreign_key(:transaction_id).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:ynab_transaction)).to be_valid
    end
  end

  describe 'scopes' do
    describe '.unmatched' do
      let!(:unmatched_tx) { create(:ynab_transaction, matched_transaction_id: nil) }
      let!(:matched_tx) { create(:ynab_transaction, matched_transaction_id: 'some_id') }
      let!(:marked_matched_tx) { create(:ynab_transaction, matched_transaction_id: nil) }

      before do
        create(:transaction_metadata, ynab_transaction: marked_matched_tx, marked_as_matched: true)
      end

      it 'returns transactions without a matched_transaction_id and not marked as matched' do
        expect(YnabTransaction.unmatched).to include(unmatched_tx)
        expect(YnabTransaction.unmatched).not_to include(matched_tx)
        expect(YnabTransaction.unmatched).not_to include(marked_matched_tx)
      end
    end
  end
end
