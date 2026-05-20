FactoryBot.define do
  factory :plan do
    ynab_id { SecureRandom.uuid }
  end
end
