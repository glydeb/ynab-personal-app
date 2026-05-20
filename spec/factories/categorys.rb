FactoryBot.define do
  factory :category do
    ynab_id { SecureRandom.uuid }
  end
end
