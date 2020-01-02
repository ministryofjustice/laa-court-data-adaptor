# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonPlatformConnection do
  before do
    class TestConnection
      include CommonPlatformConnection

      attr_reader :common_platform_shared_secret_key

      def initialize
        @common_platform_shared_secret_key = 'SHARED_SECRET_TEST'
      end

      def connection
        common_platform_connection
      end
    end
  end
  describe '#common_platform_connection' do
    let(:connection) { TestConnection.new.connection }
    it { expect(connection.headers['Authorization']).to match('TEST_SECRET') }
  end
end
