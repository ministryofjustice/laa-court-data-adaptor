# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'correct api request url' do
  subject { described_class.new(params) }

  it {
    expect(subject.instance_variable_get(:@url)).to eq(api_request_url)
  }
end
