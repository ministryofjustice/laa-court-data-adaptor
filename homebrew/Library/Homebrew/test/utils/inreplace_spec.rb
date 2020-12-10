# typed: false
# frozen_string_literal: true

require "tempfile"
require "utils/inreplace"

describe Utils::Inreplace do
  let(:file) { Tempfile.new("test") }

  before do
    file.write <<~EOS
      a
      b
      c
    EOS
  end

  after { file.unlink }

  it "raises error if there are no files given to replace" do
    expect {
      described_class.inreplace [], "d", "f"
    }.to raise_error(Utils::Inreplace::Error)
  end

  it "raises error if there is nothing to replace" do
    expect {
      described_class.inreplace file.path, "d", "f"
    }.to raise_error(Utils::Inreplace::Error)
  end

  it "raises error if there is nothing to replace in block form" do
    expect {
      described_class.inreplace(file.path) do |s|
        s.gsub!("d", "f") # rubocop:disable Performance/StringReplacement
      end
    }.to raise_error(Utils::Inreplace::Error)
  end

  it "raises error if there is no make variables to replace" do
    expect {
      described_class.inreplace(file.path) do |s|
        s.change_make_var! "VAR", "value"
        s.remove_make_var! "VAR2"
      end
    }.to raise_error(Utils::Inreplace::Error)
  end

  describe "#inreplace_pairs" do
    it "raises error if there is no old value" do
      expect {
        described_class.inreplace_pairs(file.path, [[nil, "f"]])
      }.to raise_error(Utils::Inreplace::Error)
    end
  end
end
