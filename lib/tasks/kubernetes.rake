# frozen_string_literal: true

namespace :kubernetes do
  desc 'Health check probe for k8s'
  task :healthcheck do
    raise StandardError unless `pgrep -f sidekiq`.present?
  end
end
