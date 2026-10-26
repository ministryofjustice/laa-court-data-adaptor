class HmctsCommonPlatform::CourtCentre::OrganisationUnitCode < ApplicationRecord
  validates :court_centre_id, uniqueness: true

  self.table_name = "hmcts_common_platform_court_centre_organisation_unit_codes"
end
