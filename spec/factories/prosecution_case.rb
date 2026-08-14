FactoryBot.define do
  factory :prosecution_case, class: ProsecutionCase do
    id { SecureRandom.uuid }
    body { {} }
  end
end
