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
    "PC02541" => :poca, # Application for a confiscation order in the Crown Court
    "SE20521" => :breach, # Failing to comply with the requirements of a youth rehabilitation order with intensive supervision and surveillance
    "CJ03506" => :breach, # Failing to comply with the community requirements of a suspended sentence order
    "SE20501" => :breach, # Failing to comply with the requirements of a community order
    "SO59501" => :breach, # Failing to comply with the requirements of an engagement and support order
    "SE20517" => :breach, # Failing to comply with the requirements of a youth rehabilitation order
    "SE20537" => :breach, # Fail to comply the supervision requirements of a detention and training order
    "PC00645" => :breach, # Fail to comply with drug abstinence order
    "SE20530" => :breach, # Failing to comply with the requirements of a youth rehabilitation order with fostering
    "CJ03524" => :breach, # Failed to comply with the requirements of post-custodial supervision
    "SE20502" => :breach, # Failing to comply with the community requirements of a suspended sentence order
  }.freeze

  def hearing_summaries
    body["hearingSummary"]
  end
end
