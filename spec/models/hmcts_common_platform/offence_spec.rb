RSpec.describe HmctsCommonPlatform::Offence, type: :model do
  let(:data) { JSON.parse(file_fixture("offence/all_fields.json").read).deep_symbolize_keys }
  let(:offence) { described_class.new(data) }

  it "has an id" do
    expect(offence.id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1")
  end

  it "has an offence code" do
    expect(offence.offence_code).to eql("LA12505")
  end

  it "has an order index" do
    expect(offence.order_index).to be(1)
  end

  it "has an offence title" do
    expect(offence.offence_title).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable")
  end

  it "has a mode of trial" do
    expect(offence.mode_of_trial).to eql("Either way")
  end

  it "has a start date" do
    expect(offence.start_date).to eql("2019-10-17")
  end

  it "has a wording" do
    expect(offence.wording).to eql("Random string")
  end

  it "has an allocation decision mot reason code" do
    expect(offence.allocation_decision_mot_reason_code).to eql("5")
  end

  it "has an laa appln reference status code" do
    expect(offence.laa_appln_reference_status_code).to eql("AP")
  end

  it "has an laa appln reference status date" do
    expect(offence.laa_appln_reference_status_date).to eql("2020-11-05")
  end

  it "has an laa appln reference end date" do
    expect(offence.laa_appln_reference_end_date).to eql("2021-04-11")
  end

  it "has an laa appln reference status description" do
    expect(offence.laa_appln_reference_status_description).to eql("FAKE NEWS")
  end

  it "has an laa appln reference laa contract number" do
    expect(offence.laa_appln_reference_laa_contract_number).to eql("27900")
  end

  it "has results" do
    expect(offence.results).to all(be_a(HmctsCommonPlatform::JudicialResult))
    expect(offence.results).to be_a(Array)
  end

  it "has a plea" do
    expect(offence.plea).to be_a(HmctsCommonPlatform::Plea)
  end

  it "has a verdict offence id" do
    expect(offence.verdict).to be_a(HmctsCommonPlatform::Verdict)
  end

  context "when there are only required fields" do
    let(:data) do
      JSON.parse(file_fixture("offence/required_fields.json").read).deep_symbolize_keys
    end

    it "has an id" do
      expect(offence.id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1")
    end

    it "has an offence code" do
      expect(offence.offence_code).to eql("LA12505")
    end

    it "has no order index" do
      expect(offence.order_index).to be_nil
    end

    it "has an offence title" do
      expect(offence.offence_title).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable")
    end

    it "has no mode of trial" do
      expect(offence.mode_of_trial).to be_nil
    end

    it "has a start date" do
      expect(offence.start_date).to eql("2019-10-17")
    end

    it "has a wording" do
      expect(offence.wording).to eql("Random string")
    end

    it "has no allocation decision mot reason code" do
      expect(offence.allocation_decision_mot_reason_code).to be_nil
    end

    it "has no laa appln reference status code" do
      expect(offence.laa_appln_reference_status_code).to be_nil
    end

    it "has no laa appln reference status date" do
      expect(offence.laa_appln_reference_status_date).to be_nil
    end

    it "has no laa appln reference end date" do
      expect(offence.laa_appln_reference_end_date).to be_nil
    end

    it "has no laa appln reference status description" do
      expect(offence.laa_appln_reference_status_description).to be_nil
    end

    it "has no results" do
      expect(offence.results).to eql([])
    end

    it "has no plea" do
      expect(offence.plea).to be_nil
    end

    it "has no verdict" do
      expect(offence.verdict).to be_nil
    end
  end
end
