# typed: false
# frozen_string_literal: true

describe Cask::Installer, :cask do
  describe "install" do
    let(:empty_depends_on_stub) {
      double(formula: [], cask: [], macos: nil, arch: nil, x11: nil)
    }

    it "downloads and installs a nice fresh Cask" do
      caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))

      described_class.new(caffeine).install

      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).to be_a_directory
      expect(caffeine.config.appdir.join("Caffeine.app")).to be_a_directory
    end

    it "works with dmg-based Casks" do
      asset = Cask::CaskLoader.load(cask_path("container-dmg"))

      described_class.new(asset).install

      expect(Cask::Caskroom.path.join("container-dmg", asset.version)).to be_a_directory
      expect(asset.config.appdir.join("container")).to be_a_file
    end

    it "works with tar-gz-based Casks" do
      asset = Cask::CaskLoader.load(cask_path("container-tar-gz"))

      described_class.new(asset).install

      expect(Cask::Caskroom.path.join("container-tar-gz", asset.version)).to be_a_directory
      expect(asset.config.appdir.join("container")).to be_a_file
    end

    it "works with xar-based Casks" do
      asset = Cask::CaskLoader.load(cask_path("container-xar"))

      described_class.new(asset).install

      expect(Cask::Caskroom.path.join("container-xar", asset.version)).to be_a_directory
      expect(asset.config.appdir.join("container")).to be_a_file
    end

    it "works with pure bzip2-based Casks" do
      asset = Cask::CaskLoader.load(cask_path("container-bzip2"))

      described_class.new(asset).install

      expect(Cask::Caskroom.path.join("container-bzip2", asset.version)).to be_a_directory
      expect(asset.config.appdir.join("container")).to be_a_file
    end

    it "works with pure gzip-based Casks" do
      asset = Cask::CaskLoader.load(cask_path("container-gzip"))

      described_class.new(asset).install

      expect(Cask::Caskroom.path.join("container-gzip", asset.version)).to be_a_directory
      expect(asset.config.appdir.join("container")).to be_a_file
    end

    it "blows up on a bad checksum" do
      bad_checksum = Cask::CaskLoader.load(cask_path("bad-checksum"))
      expect {
        described_class.new(bad_checksum).install
      }.to raise_error(ChecksumMismatchError)
    end

    it "blows up on a missing checksum" do
      missing_checksum = Cask::CaskLoader.load(cask_path("missing-checksum"))
      expect {
        described_class.new(missing_checksum).install
      }.to output(/Cannot verify integrity/).to_stderr
    end

    it "installs fine if sha256 :no_check is used" do
      no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))

      described_class.new(no_checksum).install

      expect(no_checksum).to be_installed
    end

    it "fails to install if sha256 :no_check is used with --require-sha" do
      no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))
      expect {
        described_class.new(no_checksum, require_sha: true).install
      }.to raise_error(/--require-sha/)
    end

    it "installs fine if sha256 :no_check is used with --require-sha and --force" do
      no_checksum = Cask::CaskLoader.load(cask_path("no-checksum"))

      described_class.new(no_checksum, require_sha: true, force: true).install

      expect(no_checksum).to be_installed
    end

    it "prints caveats if they're present" do
      with_caveats = Cask::CaskLoader.load(cask_path("with-caveats"))

      expect {
        described_class.new(with_caveats).install
      }.to output(/Here are some things you might want to know/).to_stdout

      expect(with_caveats).to be_installed
    end

    it "prints installer :manual instructions when present" do
      with_installer_manual = Cask::CaskLoader.load(cask_path("with-installer-manual"))

      expect {
        described_class.new(with_installer_manual).install
      }.to output(
        <<~EOS,
          ==> Downloading file://#{HOMEBREW_LIBRARY_PATH}/test/support/fixtures/cask/caffeine.zip
          ==> Installing Cask with-installer-manual
          To complete the installation of Cask with-installer-manual, you must also
          run the installer at:
            '#{with_installer_manual.staged_path.join("Caffeine.app")}'
          🍺  with-installer-manual was successfully installed!
        EOS
      ).to_stdout

      expect(with_installer_manual).to be_installed
    end

    it "does not extract __MACOSX directories from zips" do
      with_macosx_dir = Cask::CaskLoader.load(cask_path("with-macosx-dir"))

      described_class.new(with_macosx_dir).install

      expect(with_macosx_dir.staged_path.join("__MACOSX")).not_to be_a_directory
    end

    it "allows already-installed Casks which auto-update to be installed if force is provided" do
      with_auto_updates = Cask::CaskLoader.load(cask_path("auto-updates"))

      expect(with_auto_updates).not_to be_installed

      described_class.new(with_auto_updates).install

      expect {
        described_class.new(with_auto_updates, force: true).install
      }.not_to raise_error
    end

    # unlike the CLI, the internal interface throws exception on double-install
    it "installer method raises an exception when already-installed Casks are attempted" do
      transmission = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(transmission).not_to be_installed

      installer = described_class.new(transmission)

      installer.install

      expect {
        installer.install
      }.to raise_error(Cask::CaskAlreadyInstalledError)
    end

    it "allows already-installed Casks to be installed if force is provided" do
      transmission = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(transmission).not_to be_installed

      described_class.new(transmission).install

      expect {
        described_class.new(transmission, force: true).install
      }.not_to raise_error
    end

    it "works naked-pkg-based Casks" do
      naked_pkg = Cask::CaskLoader.load(cask_path("container-pkg"))

      described_class.new(naked_pkg).install

      expect(Cask::Caskroom.path.join("container-pkg", naked_pkg.version, "container.pkg")).to be_a_file
    end

    it "works properly with an overridden container :type" do
      naked_executable = Cask::CaskLoader.load(cask_path("naked-executable"))

      described_class.new(naked_executable).install

      expect(Cask::Caskroom.path.join("naked-executable", naked_executable.version, "naked_executable")).to be_a_file
    end

    it "works fine with a nested container" do
      nested_app = Cask::CaskLoader.load(cask_path("nested-app"))

      described_class.new(nested_app).install

      expect(nested_app.config.appdir.join("MyNestedApp.app")).to be_a_directory
    end

    it "generates and finds a timestamped metadata directory for an installed Cask" do
      caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))

      described_class.new(caffeine).install

      m_path = caffeine.metadata_timestamped_path(timestamp: :now, create: true)
      expect(caffeine.metadata_timestamped_path(timestamp: :latest)).to eq(m_path)
    end

    it "generates and finds a metadata subdirectory for an installed Cask" do
      caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))

      described_class.new(caffeine).install

      subdir_name = "Casks"
      m_subdir = caffeine.metadata_subdir(subdir_name, timestamp: :now, create: true)
      expect(caffeine.metadata_subdir(subdir_name, timestamp: :latest)).to eq(m_subdir)
    end
  end

  describe "uninstall" do
    it "fully uninstalls a Cask" do
      caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
      installer = described_class.new(caffeine)

      installer.install
      installer.uninstall

      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version, "Caffeine.app")).not_to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine")).not_to be_a_directory
    end

    it "uninstalls all versions if force is set" do
      caffeine = Cask::CaskLoader.load(cask_path("local-caffeine"))
      mutated_version = "#{caffeine.version}.1"

      described_class.new(caffeine).install

      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).not_to be_a_directory
      FileUtils.mv(Cask::Caskroom.path.join("local-caffeine", caffeine.version),
                   Cask::Caskroom.path.join("local-caffeine", mutated_version))
      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).to be_a_directory

      described_class.new(caffeine, force: true).uninstall

      expect(Cask::Caskroom.path.join("local-caffeine", caffeine.version)).not_to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine", mutated_version)).not_to be_a_directory
      expect(Cask::Caskroom.path.join("local-caffeine")).not_to be_a_directory
    end
  end
end
