FactoryBot.define do
  factory :payment do
    payment_method { %i[pos cash bank_transfer].sample }
    entry_type { %i[income expense].sample }
  end
end
