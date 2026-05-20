require 'rails_helper'

RSpec.describe ServerKnowledge, type: :model do
  describe 'associations' do
    it { should belong_to(:plan).with_primary_key(:ynab_id).with_foreign_key(:plan_id).optional }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:server_knowledge)).to be_valid
    end
  end
end
