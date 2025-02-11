# frozen_string_literal: true

RSpec.describe CommonPlatform::Api::ProsecutionCaseSearcher do
  let(:prosecution_case_reference) { "19GD1001816" }

  context "with an incorrect key" do
    subject(:search) { described_class.call(prosecution_case_reference:, connection:) }

    let(:connection) { CommonPlatform::Connection.instance.call }

    before do
      connection.headers["Ocp-Apim-Subscription-Key"] = "INCORRECT KEY"
    end

    it "returns an unauthorised response" do
      VCR.use_cassette("search_prosecution_case/unauthorised") do
        expect(search.status).to eq(401)
      end
    end
  end

  context "when searching by ProsecutionCase Reference" do
    subject(:search) { described_class.call(prosecution_case_reference:) }

    it "returns a successful response" do
      VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success") do
        expect(search.status).to eq(200)
        expect(search.body["cases"][0]["prosecutionCaseReference"]).to eq(prosecution_case_reference)
        search
      end
    end
  end

  context "when searching by National Insurance Number" do
    subject(:search) { described_class.call(national_insurance_number:) }

    let(:national_insurance_number) { "HB133542A" }

    it "returns a successful response" do
      VCR.use_cassette("search_prosecution_case/by_national_insurance_number_success") do
        expect(search.status).to eq(200)
        search
      end
    end
  end

  context "when searching by Arrest Summons Number" do
    subject(:search) { described_class.call(arrest_summons_number:) }

    let(:arrest_summons_number) { "arrest123" }

    it "returns a successful response" do
      VCR.use_cassette("search_prosecution_case/by_arrest_summons_number_success") do
        expect(search.status).to eq(200)
        search
      end
    end
  end

  context "when searching by name and date of birth" do
    subject(:search) { described_class.call(name: "George Walsh", date_of_birth:) }

    let(:date_of_birth) { "1980-01-01" }

    it "returns a successful response" do
      VCR.use_cassette("search_prosecution_case/by_name_and_date_of_birth_success") do
        expect(search.status).to eq(200)
        search
      end
    end
  end

  context "when searching by name and date_of_next_hearing" do
    subject(:search) { described_class.call(name: "George Walsh", date_of_next_hearing:) }

    let(:date_of_next_hearing) { "2020-02-17" }

    it "returns a successful response" do
      VCR.use_cassette("search_prosecution_case/by_name_and_date_of_next_hearing_success") do
        expect(search.status).to eq(200)
        search
      end
    end
  end

  context "with connection" do
    subject(:search) { described_class.call(prosecution_case_reference:, connection:) }

    let(:connection) { double("CommonPlatform::Connection") }
    let(:url) { "prosecutionCases" }
    let(:params) { { prosecutionCaseReference: prosecution_case_reference } }

    it "makes a get request" do
      expect(connection).to receive(:get).with(url, params)
      search
    end

    context "when searching by ASN and Prosecution case reference" do
      subject(:search) { described_class.call(prosecution_case_reference:, arrest_summons_number:, connection:) }

      let(:arrest_summons_number) { "arrest123" }
      let(:params) { { prosecutionCaseReference: prosecution_case_reference, defendantASN: arrest_summons_number } }

      it "makes a get request with both parameters" do
        expect(connection).to receive(:get).with(url, params)
        search
      end
    end
  end
end
