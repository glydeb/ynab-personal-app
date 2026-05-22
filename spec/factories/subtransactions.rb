FactoryBot.define do
  factory :subtransaction do
    ynab_id { SecureRandom.uuid }
  end
end
