FactoryBot.define do
  factory :payee do
    ynab_id { SecureRandom.uuid }
  end
end
