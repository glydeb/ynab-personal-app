require 'rails_helper'

RSpec.describe CategoryGroup, type: :model do
  describe 'associations' do
    it { should belong_to(:plan).with_primary_key(:ynab_id).with_foreign_key(:plan_id).optional }
    it { should have_many(:categories).with_primary_key(:ynab_id).with_foreign_key(:category_group_id).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category_group)).to be_valid
    end
  end
end
