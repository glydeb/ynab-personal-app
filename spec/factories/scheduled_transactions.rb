FactoryBot.define do
  factory :scheduled_transaction do
    ynab_id { SecureRandom.uuid }
  end
end
