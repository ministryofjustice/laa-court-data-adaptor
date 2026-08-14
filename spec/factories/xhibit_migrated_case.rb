FactoryBot.define do
  factory :xhibit_migrated_case, class: XhibitMigratedCase do
    transient do
      suffix { 1 }
    end

    case_urn { "20GD0217#{suffix}" }
    xhibit_case_number { "T20254#{suffix}" }
    court_name { "Derby Justice Centre" }
    ou_code { "B30PI00" }
    case_type { "T" }
    case_sub_type { "Either way offence" }
    mode_of_trial { "Either way" }
    defendant_id { "defendant-#{suffix}" }
    defendant_first_name { "John" }
    defendant_middle_name { nil }
    defendant_last_name { "Doe#{suffix}" }
    defendant_date_of_birth { Date.new(1987, 5, 21) }
    defendant_arrest_summons_number { "ASN#{suffix}" }
    committal_date { nil }
    sent_date { Date.new(2019, 10, 25) }
    status { "pending" }

    trait :pending do
      status { "pending" }
    end

    trait :auto_linked do
      status { "auto_linked" }
      maat_id { "1234567" }
      linked_at { Time.zone.now }
      linked_by { "SYSTEM" }
    end

    trait :manually_linked do
      status { "manually_linked" }
      maat_id { "1234567" }
      linked_at { Time.zone.now }
      linked_by { "Someone" }
    end

    trait :action_required do
      status { "action_required" }
    end
  end
end
