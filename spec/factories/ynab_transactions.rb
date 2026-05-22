FactoryBot.define do
  factory :ynab_transaction do
    ynab_id { SecureRandom.uuid }
  end
end
