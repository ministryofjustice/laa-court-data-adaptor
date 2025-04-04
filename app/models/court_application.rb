class CourtApplication < LegalCase
  def hearing_summaries
    body["hearingSummary"]
  end
end
