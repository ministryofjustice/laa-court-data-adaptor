FactoryBot.define do
  factory :court_application do
    body { {} }
    subject_id { SecureRandom.uuid }
  end
end
