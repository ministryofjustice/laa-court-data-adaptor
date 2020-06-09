# frozen_string_literal: true

RSpec.describe Current, type: :model do
  it { is_expected.to respond_to(:request_id) }
end
