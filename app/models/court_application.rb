class CourtApplication < LegalCase
  has_many :court_application_defendant_offences

  def hearing_summaries
    body["hearingSummary"]
  end
end
