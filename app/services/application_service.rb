# frozen_string_literal: true

class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  def call; end

private

  def initialize(*args, **kwargs, &block); end
end
