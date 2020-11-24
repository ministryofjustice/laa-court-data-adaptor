# frozen_string_literal: true

class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def call; end

private

  def initialize(*args, &block); end
end
