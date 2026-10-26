FactoryBot.define do
  factory :court_centre_organisation_unit_code, class: HmctsCommonPlatform::CourtCentre::OrganisationUnitCode do
    court_centre_id { SecureRandom.uuid }
    code { "B30PI00" }
    name { "Derby Justice Centre" }
  end
end
