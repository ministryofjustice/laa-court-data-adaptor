RSpec.describe HmctsCommonPlatform::SubjectSummary, type: :model do
  let(:subject_summary) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("subject_summary.json").read) }

  it "generates a JSON representation of the data" do
    expect(subject_summary.as_json[:proceedings_concluded]).to be(true)
    expect(subject_summary.as_json[:subject_id]).to eql("855ce6b7-eace-44a1-a5ea-8e530d9fbc7b")
    expect(subject_summary.as_json[:master_defendant_id]).to eql("855ce6b7-eace-44a1-a5ea-8e530d9fbc7b")
    expect(subject_summary.as_json[:defendant_asn]).to eql("VE94015")
    expect(subject_summary.as_json[:organisation_name]).to eql("Franecki, Welch and Beier-newwwwwwwwwqqqq111222233344")
    expect(subject_summary.as_json[:representation_order]).to be_a(Hash)
    expect(subject_summary.as_json[:offence_summary]).to be_a(Array)
  end

  it { expect(subject_summary.proceedings_concluded).to be(true) }
  it { expect(subject_summary.subject_id).to eql("855ce6b7-eace-44a1-a5ea-8e530d9fbc7b") }
  it { expect(subject_summary.master_defendant_id).to eql("855ce6b7-eace-44a1-a5ea-8e530d9fbc7b") }
  it { expect(subject_summary.defendant_asn).to eql("VE94015") }
  it { expect(subject_summary.organisation_name).to eql("Franecki, Welch and Beier-newwwwwwwwwqqqq111222233344") }
  it { expect(subject_summary.representation_order).to be_a(HmctsCommonPlatform::RepresentationOrder) }
  it { expect(subject_summary.offence_summary.first).to be_a(HmctsCommonPlatform::OffenceSummary) }
end
