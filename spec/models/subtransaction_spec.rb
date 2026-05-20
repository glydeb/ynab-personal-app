require 'rails_helper'

RSpec.describe Subtransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:ynab_transaction).with_primary_key(:ynab_id).with_foreign_key(:transaction_id).optional }
    it { should belong_to(:payee).with_primary_key(:ynab_id).with_foreign_key(:payee_id).optional }
    it { should belong_to(:category).with_primary_key(:ynab_id).with_foreign_key(:category_id).optional }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:subtransaction)).to be_valid
    end
  end
end
