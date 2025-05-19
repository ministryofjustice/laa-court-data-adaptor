require "rails_helper"

RSpec.describe "queues:download task" do
  subject(:download) { Rake::Task["queues:download"].execute }

  let(:link_queue) { instance_double(Aws::SQS::Queue) }
  let(:unlink_queue) { instance_double(Aws::SQS::Queue) }
  let(:resulted_queue) { instance_double(Aws::SQS::Queue) }
  let(:concluded_queue) { instance_double(Aws::SQS::Queue) }
  let(:client) { instance_double(Aws::SQS::Client) }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    allow($stdout).to receive(:puts)

    allow(Rails.configuration.x.aws).to receive_messages(
      sqs_url_link: "AWS_LINK_QUEUE_URL",
      sqs_url_unlink: "AWS_UNLINK_QUEUE_URL",
      sqs_url_hearing_resulted: "AWS_HEARING_RESULTED_QUEUE_URL",
      sqs_url_prosecution_concluded: "AWS_PROSECUTION_CONCLUDED_QUEUE_URL",
    )

    allow(Aws::SQS::Client).to receive(:new).and_return(client)
    allow(Aws::SQS::Queue).to receive(:new).with(url: "AWS_LINK_QUEUE_URL", client:).and_return(link_queue)
    allow(Aws::SQS::Queue).to receive(:new).with(url: "AWS_UNLINK_QUEUE_URL", client:).and_return(unlink_queue)
    allow(Aws::SQS::Queue).to receive(:new).with(url: "AWS_HEARING_RESULTED_QUEUE_URL", client:).and_return(resulted_queue)
    allow(Aws::SQS::Queue).to receive(:new).with(url: "AWS_PROSECUTION_CONCLUDED_QUEUE_URL", client:).and_return(concluded_queue)

    # Simulate an empty result for link queue
    allow(link_queue).to receive(:receive_messages).and_return([])

    # Simulate a call that returns 1 result and a subsequent call that returns nothing for unlink queue
    allow(unlink_queue).to receive(:receive_messages).and_return(
      [instance_double(Aws::SQS::Message, body: "unlink_message")],
      [],
    )

    # Simulate a call that returns 2 results and a subsequent call that returns nothing for resulted queue
    allow(resulted_queue).to receive(:receive_messages).and_return(
      [instance_double(Aws::SQS::Message, body: "resulted_message_1"), instance_double(Aws::SQS::Message, body: "resulted_message_2")],
      [],
    )

    # Simulate a call that returns 2 results, a call that returns 1 result, and a final call that returns nothing for concluded queue
    allow(concluded_queue).to receive(:receive_messages).and_return(
      [instance_double(Aws::SQS::Message, body: "concluded_message_1"), instance_double(Aws::SQS::Message, body: "concluded_message_2")],
      [instance_double(Aws::SQS::Message, body: "concluded_message_3")],
      [],
    )
  end

  after do
    Rake::Task["queues:download"].reenable
  end

  it "outputs queue data from 4 queues to the console" do
    download
    expect($stdout).to have_received(:puts).with(
      '[{"queue":"link_queue","messages":[]},'\
      '{"queue":"unlink_queue","messages":["unlink_message"]},'\
      '{"queue":"resulted_hearings_queue","messages":["resulted_message_1","resulted_message_2"]},'\
      '{"queue":"concluded_prosecutions_queue","messages":["concluded_message_1","concluded_message_2","concluded_message_3"]}]',
    )
  end
end
