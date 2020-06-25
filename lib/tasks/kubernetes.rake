# frozen_string_literal: true

namespace :kubernetes do
  desc 'Health check probe for k8s'
  task healthcheck: :environment do
    raise StandardError if `pgrep -f sidekiq`.blank?
  end
end
