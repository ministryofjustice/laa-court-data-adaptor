# frozen_string_literal: true

RSpec.describe LinkXhibitCaseWorker, type: :worker do
  subject(:perform_link) { described_class.new.perform(xhibit_case.id, maat_id) }

  let(:maat_id) { 6_672_961 }
  let(:xhibit_case) { create(:xhibit_migrated_case) }
  let(:processor) { instance_double(ProcessXhibitCases, link_to_common_platform: nil) }

  before { allow(ProcessXhibitCases).to receive(:new).and_return(processor) }

  it "links the case to Common Platform" do
    perform_link

    expect(processor).to have_received(:link_to_common_platform).with(xhibit_case, maat_id)
  end

  %i[auto_linked manually_linked action_required].each do |status|
    context "when the case is already #{status}" do
      let(:xhibit_case) { create(:xhibit_migrated_case, status) }

      it "does not link it" do
        perform_link

        expect(processor).not_to have_received(:link_to_common_platform)
      end
    end
  end

  context "when the case does not exist" do
    subject(:perform_link) { described_class.new.perform(SecureRandom.uuid, maat_id) }

    it "does nothing" do
      expect { perform_link }.not_to raise_error
      expect(processor).not_to have_received(:link_to_common_platform)
    end
  end
end
