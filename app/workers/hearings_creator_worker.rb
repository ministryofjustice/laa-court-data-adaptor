# frozen_string_literal: true

class HearingsCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, hearing_resulted_json)
    Current.set(request_id: request_id) do
      HearingsCreator.call(
        hearing_resulted_data: JSON.parse(hearing_resulted_json),
        queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
      )
    end
  end
end
