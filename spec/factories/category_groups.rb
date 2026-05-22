FactoryBot.define do
  factory :category_group do
    ynab_id { SecureRandom.uuid }
  end
end
