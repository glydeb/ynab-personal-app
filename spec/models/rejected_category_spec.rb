require 'rails_helper'

RSpec.describe RejectedCategory, type: :model do
  describe 'associations' do
    it { should belong_to(:ynab_transaction).with_primary_key(:ynab_id).with_foreign_key(:ynab_transaction_id) }
    it { should belong_to(:category).with_primary_key(:ynab_id).with_foreign_key(:category_id) }
  end
end
