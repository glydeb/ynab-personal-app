FactoryBot.define do
  factory :account do
    ynab_id { SecureRandom.uuid }
  end
end
