FactoryBot.define do
  factory :payment do
    payment_method { [:pos, :contanti, :bonifico, :indefinito].sample }
    entry_type { [:entrata, :uscita].sample }
    payed { true }
  end
end
