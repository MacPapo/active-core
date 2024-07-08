FactoryBot.define do
  factory :payment do
    amount { Faker::Commerce.price(range: 10..100.0) }
    date { Faker::Date.backward(days: 14) }
    payment_method { [:pos, :contanti, :bonifico, :indefinito].sample }
    payment_type { [:abbonamento, :quota, :altro].sample }
    entry_type { [:entrata, :uscita].sample }
    payed { true }
  end
end
