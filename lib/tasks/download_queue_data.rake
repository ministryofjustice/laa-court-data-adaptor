namespace :queues do
  desc "Export all messages from all MAAT queues and print them to the console."
  task download: :environment do |_task, _args|
    client = Aws::SQS::Client.new
    queue_urls = {
      link_queue: Rails.configuration.x.aws.sqs_url_link,
      unlink_queue: Rails.configuration.x.aws.sqs_url_unlink,
      resulted_hearings_queue: Rails.configuration.x.aws.sqs_url_hearing_resulted,
      concluded_prosecutions_queue: Rails.configuration.x.aws.sqs_url_prosecution_concluded,
    }

    output = queue_urls.map do |queue_name, url|
      queue = Aws::SQS::Queue.new(url:, client:)

      ret = []
      loop do
        # Note that this will mean the received messages are invisible to clients for the next 10 seconds
        # to allow the script to finish without duplicating messages
        messages = queue.receive_messages(
          max_number_of_messages: 10,
          visibility_timeout: 10,
        )

        messages.each do |message|
          ret << message.body
        end

        break unless messages.any?
      end

      {
        queue: queue_name,
        messages: ret,
      }
    end

    puts output.to_json
  end
end
