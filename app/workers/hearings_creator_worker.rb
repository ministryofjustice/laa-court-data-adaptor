# frozen_string_literal: true

class HearingsCreatorWorker
  include Sidekiq::Worker

  def perform(request_id, hearing_resulted_data)
    Current.set(request_id: request_id) do
      HearingsCreator.call(
        hearing_resulted_data: hearing_resulted_data,
        queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
      )
    end
  end
end
