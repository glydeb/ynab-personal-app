require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should belong_to(:plan).with_primary_key(:ynab_id).with_foreign_key(:plan_id).optional }
    it { should belong_to(:category_group).with_primary_key(:ynab_id).with_foreign_key(:category_group_id).optional }
    it { should have_many(:ynab_transactions).with_primary_key(:ynab_id).with_foreign_key(:category_id).dependent(:nullify) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end
  end
end
