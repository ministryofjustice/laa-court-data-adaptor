FactoryBot.define do
  factory :prosecution_case_defendant_offence, class: ProsecutionCaseDefendantOffence do
    prosecution_case_id { SecureRandom.uuid }
    defendant_id { SecureRandom.uuid }
    offence_id { SecureRandom.uuid }
    status_date { "2023-01-01" }
    defence_organisation { {} }
  end
end
