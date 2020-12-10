# typed: false
# frozen_string_literal: true

require "formula"
require "formula_installer"
require "keg"
require "tab"
require "cmd/install"
require "test/support/fixtures/testball"
require "test/support/fixtures/testball_bottle"

describe FormulaInstaller do
  alias_matcher :pour_bottle, :be_pour_bottle

  matcher :be_poured_from_bottle do
    match(&:poured_from_bottle)
  end

  def temporarily_install_bottle(formula)
    expect(formula).not_to be_latest_version_installed
    expect(formula).to be_bottled
    expect(formula).to pour_bottle

    stub_formula_loader formula
    stub_formula_loader formula("gcc") { url "gcc-1.0" }
    stub_formula_loader formula("patchelf") { url "patchelf-1.0" }
    allow(Formula["patchelf"]).to receive(:latest_version_installed?).and_return(true)

    fi = FormulaInstaller.new(formula)
    fi.fetch
    fi.install

    keg = Keg.new(formula.prefix)

    expect(formula).to be_latest_version_installed

    begin
      expect(Tab.for_keg(keg)).to be_poured_from_bottle

      yield formula
    ensure
      keg.unlink
      keg.uninstall
      formula.clear_cache
      formula.bottle.clear_cache
    end

    expect(keg).not_to exist
    expect(formula).not_to be_latest_version_installed
  end

  specify "basic bottle install" do
    allow(DevelopmentTools).to receive(:installed?).and_return(false)
    Homebrew.install_args.parse(["testball_bottle"])
    temporarily_install_bottle(TestballBottle.new) do |f|
      # Copied directly from formula_installer_spec.rb
      # as we expect the same behavior.

      # Test that things made it into the Keg
      expect(f.bin).to be_a_directory

      expect(f.libexec).to be_a_directory

      expect(f.prefix/"main.c").not_to exist

      # Test that things made it into the Cellar
      keg = Keg.new f.prefix
      keg.link

      bin = HOMEBREW_PREFIX/"bin"
      expect(bin).to be_a_directory
    end
  end

  specify "build tools error" do
    allow(DevelopmentTools).to receive(:installed?).and_return(false)

    # Testball doesn't have a bottle block, so use it to test this behavior
    formula = Testball.new

    expect(formula).not_to be_latest_version_installed
    expect(formula).not_to be_bottled

    expect {
      described_class.new(formula).install
    }.to raise_error(BuildToolsError)

    expect(formula).not_to be_latest_version_installed
  end
end
