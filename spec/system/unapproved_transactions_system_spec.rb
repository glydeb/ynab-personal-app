require 'rails_helper'

RSpec.describe 'Unapproved Transactions JS Interactions', type: :system do
  let!(:plan) { create(:plan) }
  let!(:payee) { create(:payee, plan: plan) }

  before do
    # Assuming standard Rails 8 configuration with capybara/selenium
    # If the local environment doesn't have chrome/selenium, this might be skipped or fail.
    driven_by(:selenium, using: :headless_chrome) rescue nil
  end

  it 'allows toggling similar payees via JS', js: true do
    create(:ynab_transaction, plan: plan, approved: false, payee: payee, category: nil, amount: -1000)
    create(:ynab_transaction, plan: plan, approved: false, payee: payee, category: nil, amount: -2000)

    visit plan_unapproved_transactions_path(plan)

    # Both checkboxes should be unchecked
    checkboxes = all('.row-checkbox')
    expect(checkboxes.count).to eq(2)
    checkboxes.each { |cb| expect(cb).not_to be_checked }

    # Click the first payee cell
    first("td[data-payee-id='#{payee.ynab_id}']").click

    # Both should now be checked
    checkboxes = all('.row-checkbox')
    checkboxes.each { |cb| expect(cb).to be_checked }

    # Click again to uncheck
    first("td[data-payee-id='#{payee.ynab_id}']").click
    checkboxes = all('.row-checkbox')
    checkboxes.each { |cb| expect(cb).not_to be_checked }
  end
end
