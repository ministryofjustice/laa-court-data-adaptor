FactoryBot.define do
  factory :laa_reference, class: LaaReference do
    user_name {  "test_user" }
    defendant_id { "67d948d1-1792-4565-a522-8ab2425827e8" }
    maat_reference { "700111" }
    linked { true }
  end
end
