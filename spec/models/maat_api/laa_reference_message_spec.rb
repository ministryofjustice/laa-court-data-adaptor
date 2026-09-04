RSpec.describe MaatApi::LaaReferenceMessage do
  subject(:message) { described_class.new(laa_reference).generate }

  let(:laa_reference) do
    instance_double(
      MaatApi::LaaReference,
      maat_reference: "1234567",
      case_urn: "30DI0570888",
      defendant_asn: "ARREST123",
      cjs_area_code: "1",
      user_name: "test-user",
      cjs_location: "B01LY",
      doc_language: "EN",
      is_active?: true,
      can_update_laa_status?: can_update_laa_status,
      defendant: { defendantId: "4b463e6a-105b-433b-a88d-057d6e645bfb" },
      sessions: [{ courtLocation: "B01LY", dateOfHearing: "2020-08-17" }],
    )
  end

  context "when the LAA status cannot be updated" do
    let(:can_update_laa_status) { false }

    it "builds the MAAT link payload" do
      expect(message).to eq(
        maatId: "1234567",
        caseUrn: "30DI0570888",
        asn: "ARREST123",
        cjsAreaCode: "1",
        createdUser: "test-user",
        cjsLocation: "B01LY",
        docLanguage: "EN",
        isActive: true,
        canUpdateLaaStatus: false,
        defendant: { defendantId: "4b463e6a-105b-433b-a88d-057d6e645bfb" },
        sessions: [{ courtLocation: "B01LY", dateOfHearing: "2020-08-17" }],
      )
    end
  end

  context "when the LAA status can be updated" do
    let(:can_update_laa_status) { true }

    it "flags it in the payload" do
      expect(message).to include(canUpdateLaaStatus: true)
    end
  end
end
