require 'rails_helper'

RSpec.describe Payee, type: :model do
  describe 'associations' do
    it { should belong_to(:plan).with_primary_key(:ynab_id).with_foreign_key(:plan_id).optional }
    it { should have_many(:ynab_transactions).with_primary_key(:ynab_id).with_foreign_key(:payee_id).dependent(:nullify) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:payee)).to be_valid
    end
  end
end
