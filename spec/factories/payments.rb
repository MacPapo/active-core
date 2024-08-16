FactoryBot.define do
  factory :payment do
    payment_method { [ :pos, :cash, :bank_transfer ].sample }
    entry_type { [ :income, :expense ].sample }
  end
end
