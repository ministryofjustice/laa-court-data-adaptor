# typed: false
# frozen_string_literal: true

require "hardware"

describe Hardware::CPU do
  describe "::type" do
    let(:cpu_types) {
      [
        :arm,
        :intel,
        :ppc,
        :dunno,
      ]
    }

    it "returns the current CPU's type as a symbol, or :dunno if it cannot be detected" do
      expect(cpu_types).to include(described_class.type)
    end
  end

  describe "::family" do
    let(:cpu_families) {
      [
        :arm_firestorm_icestorm,
        :arm_hurricane_zephyr,
        :arm_lightning_thunder,
        :arm_monsoon_mistral,
        :arm_twister,
        :arm_typhoon,
        :arm_vortex_tempest,
        :atom,
        :broadwell,
        :core,
        :core2,
        :dothan,
        :haswell,
        :icelake,
        :ivybridge,
        :kabylake,
        :merom,
        :nehalem,
        :penryn,
        :prescott,
        :presler,
        :sandybridge,
        :skylake,
        :westmere,
        :dunno,
      ]
    }

    it "returns the current CPU's family name as a symbol, or :dunno if it cannot be detected" do
      expect(cpu_families).to include described_class.family
    end

    context "when hw.cpufamily is 0x573b5eec on a Mac", :needs_macos do
      before do
        allow(described_class)
          .to receive(:sysctl_int)
          .with("hw.cpufamily")
          .and_return(0x573b5eec)
      end

      it "returns :arm_firestorm_icestorm on ARM" do
        allow(described_class).to receive(:arm?).and_return(true)
        allow(described_class).to receive(:intel?).and_return(false)

        expect(described_class.family).to eq(:arm_firestorm_icestorm)
      end

      it "returns :westmere on Intel" do
        allow(described_class).to receive(:arm?).and_return(false)
        allow(described_class).to receive(:intel?).and_return(true)

        expect(described_class.family).to eq(:westmere)
      end
    end
  end
end
