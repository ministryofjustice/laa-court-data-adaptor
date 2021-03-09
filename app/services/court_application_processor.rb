# frozen_string_literal: true

# 1. Recieve hearing payload from CP
# 2. Pull out courtApplications
# 3. Filter out courtApplications with no defendant
# 4. Filter out unlinked defendants (no MAAT id)
# 5. Build MAAT API message payload for each defendant
# 6. Publish messages to queue

class CourtApplicationProcessor < ApplicationService
  def call(court_applications)
    return if court_applications.empty?

    # for each court application,
    # fetch all defendant ids
    # for each defendant id,
    # make call to CP to get defendant info
  end
end
