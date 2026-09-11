# frozen_string_literal: true

# Aws::SQS::Client is instantiated as a default argument in Sqs::MessagePublisher,
# so without this every publish would attempt a real request.
Aws.config[:stub_responses] = true

# Queue URLs have to be present and distinct in test: MessagePublisher no-ops on a
# blank URL, which makes every `queue_url:` assertion in the suite vacuous.
%i[sqs_url_link sqs_url_unlink sqs_url_hearing_resulted sqs_url_prosecution_concluded].each do |name|
  Rails.configuration.x.aws[name] = "https://sqs.test/#{name}" if Rails.configuration.x.aws[name].blank?
end
