require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'associations' do
    it { should have_many(:server_knowledges).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:accounts).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:payees).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:category_groups).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:categories).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:ynab_transactions).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
    it { should have_many(:scheduled_transactions).with_primary_key(:ynab_id).with_foreign_key(:plan_id).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:plan)).to be_valid
    end
  end
end
