# typed: false
# frozen_string_literal: true

require "utils/spdx"

describe SPDX do
  describe ".license_data" do
    it "has the license list version" do
      expect(described_class.license_data["licenseListVersion"]).not_to eq(nil)
    end

    it "has the release date" do
      expect(described_class.license_data["releaseDate"]).not_to eq(nil)
    end

    it "has licenses" do
      expect(described_class.license_data["licenses"].length).not_to eq(0)
    end
  end

  describe ".exception_data" do
    it "has the license list version" do
      expect(described_class.exception_data["licenseListVersion"]).not_to eq(nil)
    end

    it "has the release date" do
      expect(described_class.exception_data["releaseDate"]).not_to eq(nil)
    end

    it "has exceptions" do
      expect(described_class.exception_data["exceptions"].length).not_to eq(0)
    end
  end

  describe ".download_latest_license_data!", :needs_network do
    let(:tmp_json_path) { Pathname.new(TEST_TMPDIR) }

    after do
      FileUtils.rm_f tmp_json_path/"spdx_licenses.json"
      FileUtils.rm_f tmp_json_path/"spdx_exceptions.json"
    end

    it "downloads latest license data" do
      described_class.download_latest_license_data! to: tmp_json_path
      expect(tmp_json_path/"spdx_licenses.json").to exist
      expect(tmp_json_path/"spdx_exceptions.json").to exist
    end
  end

  describe ".parse_license_expression" do
    it "returns a single license" do
      expect(described_class.parse_license_expression("MIT").first).to eq ["MIT"]
    end

    it "returns a single license with plus" do
      expect(described_class.parse_license_expression("Apache-2.0+").first).to eq ["Apache-2.0+"]
    end

    it "returns multiple licenses with :any" do
      expect(described_class.parse_license_expression(any_of: ["MIT", "0BSD"]).first).to eq ["MIT", "0BSD"]
    end

    it "returns multiple licenses with :all" do
      expect(described_class.parse_license_expression(all_of: ["MIT", "0BSD"]).first).to eq ["MIT", "0BSD"]
    end

    it "returns multiple licenses with plus" do
      expect(described_class.parse_license_expression(any_of: ["MIT", "EPL-1.0+"]).first).to eq ["MIT", "EPL-1.0+"]
    end

    it "returns multiple licenses with array" do
      expect(described_class.parse_license_expression(["MIT", "EPL-1.0+"]).first).to eq ["MIT", "EPL-1.0+"]
    end

    it "returns license and exception" do
      license_expression = { "MIT" => { with: "LLVM-exception" } }
      expect(described_class.parse_license_expression(license_expression)).to eq [["MIT"], ["LLVM-exception"]]
    end

    it "returns licenses and exceptions for compex license expressions" do
      license_expression = { any_of: [
        "MIT",
        :public_domain,
        all_of: ["0BSD", "Zlib"],
        "curl" => { with: "LLVM-exception" },
      ] }
      result = [["MIT", :public_domain, "curl", "0BSD", "Zlib"], ["LLVM-exception"]]
      expect(described_class.parse_license_expression(license_expression)).to eq result
    end

    it "returns :public_domain" do
      expect(described_class.parse_license_expression(:public_domain).first).to eq [:public_domain]
    end

    it "returns :cannot_represent" do
      expect(described_class.parse_license_expression(:cannot_represent).first).to eq [:cannot_represent]
    end
  end

  describe ".valid_license?" do
    it "returns true for valid license identifier" do
      expect(described_class.valid_license?("MIT")).to eq true
    end

    it "returns false for invalid license identifier" do
      expect(described_class.valid_license?("foo")).to eq false
    end

    it "returns true for deprecated license identifier" do
      expect(described_class.valid_license?("GPL-1.0")).to eq true
    end

    it "returns true for license identifier with plus" do
      expect(described_class.valid_license?("Apache-2.0+")).to eq true
    end

    it "returns true for :public_domain" do
      expect(described_class.valid_license?(:public_domain)).to eq true
    end

    it "returns true for :cannot_represent" do
      expect(described_class.valid_license?(:cannot_represent)).to eq true
    end

    it "returns false for invalid symbol" do
      expect(described_class.valid_license?(:invalid_symbol)).to eq false
    end
  end

  describe ".deprecated_license?" do
    it "returns true for deprecated license identifier" do
      expect(described_class.deprecated_license?("GPL-1.0")).to eq true
    end

    it "returns false for non-deprecated license identifier" do
      expect(described_class.deprecated_license?("MIT")).to eq false
    end

    it "returns false for invalid license identifier" do
      expect(described_class.deprecated_license?("foo")).to eq false
    end

    it "returns false for :public_domain" do
      expect(described_class.deprecated_license?(:public_domain)).to eq false
    end

    it "returns false for :cannot_represent" do
      expect(described_class.deprecated_license?(:cannot_represent)).to eq false
    end
  end

  describe ".valid_license_exception?" do
    it "returns true for valid license exception identifier" do
      expect(described_class.valid_license_exception?("LLVM-exception")).to eq true
    end

    it "returns false for invalid license exception identifier" do
      expect(described_class.valid_license_exception?("foo")).to eq false
    end

    it "returns false for deprecated license exception identifier" do
      expect(described_class.valid_license_exception?("Nokia-Qt-exception-1.1")).to eq false
    end
  end

  describe ".license_expression_to_string" do
    it "returns a single license" do
      expect(described_class.license_expression_to_string("MIT")).to eq "MIT"
    end

    it "returns a single license with plus" do
      expect(described_class.license_expression_to_string("Apache-2.0+")).to eq "Apache-2.0+"
    end

    it "returns multiple licenses with :any" do
      expect(described_class.license_expression_to_string(any_of: ["MIT", "0BSD"])).to eq "MIT or 0BSD"
    end

    it "returns multiple licenses with :all" do
      expect(described_class.license_expression_to_string(all_of: ["MIT", "0BSD"])).to eq "MIT and 0BSD"
    end

    it "returns multiple licenses with plus" do
      expect(described_class.license_expression_to_string(any_of: ["MIT", "EPL-1.0+"])).to eq "MIT or EPL-1.0+"
    end

    it "returns license and exception" do
      license_expression = { "MIT" => { with: "LLVM-exception" } }
      expect(described_class.license_expression_to_string(license_expression)).to eq "MIT with LLVM-exception"
    end

    it "returns licenses and exceptions for compex license expressions" do
      license_expression = { any_of: [
        "MIT",
        :public_domain,
        all_of: ["0BSD", "Zlib"],
        "curl" => { with: "LLVM-exception" },
      ] }
      result = "MIT or Public Domain or (0BSD and Zlib) or (curl with LLVM-exception)"
      expect(described_class.license_expression_to_string(license_expression)).to eq result
    end

    it "returns :public_domain" do
      expect(described_class.license_expression_to_string(:public_domain)).to eq "Public Domain"
    end

    it "returns :cannot_represent" do
      expect(described_class.license_expression_to_string(:cannot_represent)).to eq "Cannot Represent"
    end
  end

  describe ".license_version_info" do
    it "returns license without version" do
      expect(described_class.license_version_info("MIT")).to eq ["MIT"]
    end

    it "returns :public_domain without version" do
      expect(described_class.license_version_info(:public_domain)).to eq [:public_domain]
    end

    it "returns license with version" do
      expect(described_class.license_version_info("Apache-2.0")).to eq ["Apache", "2.0", false]
    end

    it "returns license with version and plus" do
      expect(described_class.license_version_info("Apache-2.0+")).to eq ["Apache", "2.0", true]
    end

    it "returns more complicated license with version" do
      expect(described_class.license_version_info("CC-BY-3.0-AT")).to eq ["CC-BY", "3.0", false]
    end

    it "returns more complicated license with version and plus" do
      expect(described_class.license_version_info("CC-BY-3.0-AT+")).to eq ["CC-BY", "3.0", true]
    end

    it "returns license with -only" do
      expect(described_class.license_version_info("GPL-3.0-only")).to eq ["GPL", "3.0", false]
    end

    it "returns license with -or-later" do
      expect(described_class.license_version_info("GPL-3.0-or-later")).to eq ["GPL", "3.0", true]
    end
  end

  describe ".licenses_forbid_installation?" do
    let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }
    let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }
    let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }
    let(:multiple_forbidden) {
      {
        "MIT"  => described_class.license_version_info("MIT"),
        "0BSD" => described_class.license_version_info("0BSD"),
      }
    }
    let(:any_of_license) { { any_of: ["MIT", "0BSD"] } }
    let(:all_of_license) { { all_of: ["MIT", "0BSD"] } }
    let(:nested_licenses) {
      {
        any_of: [
          "MIT",
          { "MIT" => { with: "LLVM-exception" } },
          { any_of: ["MIT", "0BSD"] },
        ],
      }
    }
    let(:license_exception) { { "MIT" => { with: "LLVM-exception" } } }

    it "allows installation with no forbidden licenses" do
      expect(described_class.licenses_forbid_installation?("MIT", {})).to eq false
    end

    it "allows installation with non-forbidden license" do
      expect(described_class.licenses_forbid_installation?("0BSD", mit_forbidden)).to eq false
    end

    it "forbids installation with forbidden license" do
      expect(described_class.licenses_forbid_installation?("MIT", mit_forbidden)).to eq true
    end

    it "allows installation of later license version" do
      expect(described_class.licenses_forbid_installation?("EPL-2.0", epl_1_forbidden)).to eq false
    end

    it "forbids installation of later license version with plus in forbidden license list" do
      expect(described_class.licenses_forbid_installation?("EPL-2.0", epl_1_plus_forbidden)).to eq true
    end

    it "allows installation when one of the any_of licenses is allowed" do
      expect(described_class.licenses_forbid_installation?(any_of_license, mit_forbidden)).to eq false
    end

    it "forbids installation when none of the any_of licenses are allowed" do
      expect(described_class.licenses_forbid_installation?(any_of_license, multiple_forbidden)).to eq true
    end

    it "forbids installation when one of the all_of licenses is allowed" do
      expect(described_class.licenses_forbid_installation?(all_of_license, mit_forbidden)).to eq true
    end

    it "allows installation with license + exception that aren't forbidden" do
      expect(described_class.licenses_forbid_installation?(license_exception, epl_1_forbidden)).to eq false
    end

    it "forbids installation with license + exception that are't forbidden" do
      expect(described_class.licenses_forbid_installation?(license_exception, mit_forbidden)).to eq true
    end

    it "allows installation with nested licenses with no forbidden licenses" do
      expect(described_class.licenses_forbid_installation?(nested_licenses, epl_1_forbidden)).to eq false
    end

    it "allows installation with nested licenses when second hash item matches" do
      expect(described_class.licenses_forbid_installation?(nested_licenses, mit_forbidden)).to eq false
    end

    it "forbids installation with nested licenses when all licenses are forbidden" do
      expect(described_class.licenses_forbid_installation?(nested_licenses, multiple_forbidden)).to eq true
    end
  end

  describe ".forbidden_licenses_include?" do
    let(:mit_forbidden) { { "MIT" => described_class.license_version_info("MIT") } }
    let(:epl_1_forbidden) { { "EPL-1.0" => described_class.license_version_info("EPL-1.0") } }
    let(:epl_1_plus_forbidden) { { "EPL-1.0+" => described_class.license_version_info("EPL-1.0+") } }

    it "returns false with no forbidden licenses" do
      expect(described_class.forbidden_licenses_include?("MIT", {})).to eq false
    end

    it "returns false with no matching forbidden licenses" do
      expect(described_class.forbidden_licenses_include?("MIT", epl_1_forbidden)).to eq false
    end

    it "returns true with matching license" do
      expect(described_class.forbidden_licenses_include?("MIT", mit_forbidden)).to eq true
    end

    it "returns false with later version of forbidden license" do
      expect(described_class.forbidden_licenses_include?("EPL-2.0", epl_1_forbidden)).to eq false
    end

    it "returns true with later version of forbidden license with later versions forbidden" do
      expect(described_class.forbidden_licenses_include?("EPL-2.0", epl_1_plus_forbidden)).to eq true
    end
  end
end
