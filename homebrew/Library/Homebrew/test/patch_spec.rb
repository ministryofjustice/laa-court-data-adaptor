# typed: false
# frozen_string_literal: true

require "patch"

describe Patch do
  describe "#create" do
    context "simple patch" do
      subject { described_class.create(:p2, nil) }

      it { is_expected.to be_kind_of ExternalPatch }
      it { is_expected.to be_external }
      its(:strip) { is_expected.to eq(:p2) }
    end

    context "string patch" do
      subject { described_class.create(:p0, "foo") }

      it { is_expected.to be_kind_of StringPatch }
      its(:strip) { is_expected.to eq(:p0) }
    end

    context "string patch without strip" do
      subject { described_class.create("foo", nil) }

      it { is_expected.to be_kind_of StringPatch }
      its(:strip) { is_expected.to eq(:p1) }
    end

    context "data patch" do
      subject { described_class.create(:p0, :DATA) }

      it { is_expected.to be_kind_of DATAPatch }
      its(:strip) { is_expected.to eq(:p0) }
    end

    context "data patch without strip" do
      subject { described_class.create(:DATA, nil) }

      it { is_expected.to be_kind_of DATAPatch }
      its(:strip) { is_expected.to eq(:p1) }
    end

    it "raises an error for unknown values" do
      expect {
        described_class.create(Object.new)
      }.to raise_error(ArgumentError)

      expect {
        described_class.create(Object.new, Object.new)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#patch_files" do
    subject { described_class.create(:p2, nil) }

    context "empty patch" do
      its(:resource) { is_expected.to be_kind_of Resource::PatchResource }
      its(:patch_files) { is_expected.to eq(subject.resource.patch_files) }
      its(:patch_files) { is_expected.to eq([]) }
    end

    it "returns applied patch files" do
      subject.resource.apply("patch1.diff")
      expect(subject.patch_files).to eq(["patch1.diff"])

      subject.resource.apply("patch2.diff", "patch3.diff")
      expect(subject.patch_files).to eq(["patch1.diff", "patch2.diff", "patch3.diff"])

      subject.resource.apply(["patch4.diff", "patch5.diff"])
      expect(subject.patch_files.count).to eq(5)

      subject.resource.apply("patch4.diff", ["patch5.diff", "patch6.diff"], "patch7.diff")
      expect(subject.patch_files.count).to eq(7)
    end
  end
end

describe EmbeddedPatch do
  describe "#new" do
    subject { described_class.new(:p1) }

    its(:inspect) { is_expected.to eq("#<EmbeddedPatch: :p1>") }
  end
end

describe ExternalPatch do
  subject { described_class.new(:p1) { url "file:///my.patch" } }

  describe "#url" do
    its(:url) { is_expected.to eq("file:///my.patch") }
  end

  describe "#inspect" do
    its(:inspect) { is_expected.to eq('#<ExternalPatch: :p1 "file:///my.patch">') }
  end

  describe "#cached_download" do
    before do
      allow(subject.resource).to receive(:cached_download).and_return("/tmp/foo.tar.gz")
    end

    its(:cached_download) { is_expected.to eq("/tmp/foo.tar.gz") }
  end
end
