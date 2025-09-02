class CourtApplication < ApplicationRecord
  validates :body, presence: true

  # TODO: When Appeals V2 is switched on we can remove this as we will remove the logic that relies on them
  SUPPORTED_COURT_APPLICATION_TITLES = [
    "Appeal against conviction and sentence by a Magistrates' Court to the Crown Court",
    "Appeal against conviction by a Magistrates' Court to the Crown Court",
    "Appeal against sentence by a Magistrates' Court to the Crown Court",
  ].freeze

  # These are the codes and categories of the types of court applications that we primarily support
  # and will return inside a prosecution case payload. Other court application types
  # will still be returned when attached to specific hearings.
  SUPPORTED_COURT_APPLICATION_CATEGORIES = {
    "MC80801" => :appeal, # Appeal against conviction and sentence by a Magistrates' Court to the Crown Court
    "MC80802" => :appeal, # Appeal against conviction by a Magistrates' Court to the Crown Court
    "MC80803" => :appeal, # Appeal against sentence by a Magistrates' Court to the Crown Court
    "CJ08521" => :breach, # Failing to comply with the requirements of a youth rehabilitation order with intensive supervision and surveillance
    "CJ03510" => :breach, # Failing to comply with the requirements of a community order
    "SO59501" => :breach, # Failing to comply with the requirements of an engagement and support order
    "UNKNOWN1" => :breach, # Failing to comply with the requirements of an engagement and support order
    "PC00700" => :breach, # Fail to comply the supervision requirements of a detention and training order
    "PC00645" => :breach, # Fail to comply with drug abstinence order
    "MC80508" => :breach, # Fail to comply with court order for bind over
    "CJ08514" => :breach, # Failing to comply with the requirements of a youth rehabilitation order with fostering
    "CJ03524" => :breach, # Failed to comply with the requirements of post-custodial supervision
    "CJ03506" => :breach, # Failing to comply with the community requirements of a suspended sentence order
    "UNKNOWN2" => :poca, # Application for a confiscation order in the Crown Court
  }.freeze

  def hearing_summaries
    body["hearingSummary"]
  end
end
