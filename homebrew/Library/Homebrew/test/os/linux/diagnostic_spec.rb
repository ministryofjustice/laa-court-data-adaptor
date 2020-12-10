# typed: false
# frozen_string_literal: true

require "diagnostic"

describe Homebrew::Diagnostic::Checks do
  specify "#check_supported_architecture" do
    allow(Hardware::CPU).to receive(:type).and_return(:arm64)

    expect(subject.check_supported_architecture)
      .to match(/Your CPU architecture .+ is not supported/)
  end

  specify "#check_glibc_minimum_version" do
    allow(OS::Linux::Glibc).to receive(:below_minimum_version?).and_return(true)

    expect(subject.check_glibc_minimum_version)
      .to match(/Your system glibc .+ is too old/)
  end

  specify "#check_kernel_minimum_version" do
    allow(OS::Linux::Kernel).to receive(:below_minimum_version?).and_return(true)

    expect(subject.check_kernel_minimum_version)
      .to match(/Your Linux kernel .+ is too old/)
  end
end
