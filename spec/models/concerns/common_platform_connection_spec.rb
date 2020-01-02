# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonPlatformConnection do
  before do
    class TestConnection
      include CommonPlatformConnection
      def connection
        common_platform_connection
      end
    end
  end
  describe '#common_platform_connection' do
    let(:connection) { TestConnection.new.connection }
    it { expect(connection.headers['Authorization']).to_not be_blank }
  end
end
