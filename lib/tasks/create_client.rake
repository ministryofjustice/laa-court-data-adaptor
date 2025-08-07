namespace :client do
  desc "Create an oauth client. \
        Example: bundle exec rails client:create name=some-name uid=some-id secret=some-secret"
  task create: :environment do |_task, _args|
    raise "Do not use this in production!" if Rails.env.production?

    name = ENV["name"]
    uid = ENV["uid"]
    secret = ENV["secret"]
    Doorkeeper::Application.create!(name:, uid:, secret:)
  end
end
