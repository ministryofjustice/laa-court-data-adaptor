# typed: false
# frozen_string_literal: true

require_relative "shared_examples"

describe UnpackStrategy::Lzip do
  let(:path) { TEST_FIXTURE_DIR/"test.lz" }

  include_examples "UnpackStrategy::detect"
end
