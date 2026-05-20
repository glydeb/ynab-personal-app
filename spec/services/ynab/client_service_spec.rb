require 'rails_helper'

RSpec.describe Ynab::ClientService do
  describe '#client' do
    it 'initializes a YNAB API client with the credentials token' do
      allow(Rails.application.credentials).to receive(:ynab_access_token!).and_return('fake_token')
      service = described_class.new
      expect(service.client).to be_a(YNAB::API)
    end
  end
end
