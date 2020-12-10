# typed: false
# frozen_string_literal: true

require "cask/cmd/audit"
require "cask/cmd/fetch"
require "cask/cmd/install"
require "cask/cask_loader"
require "cask/download"
require "cask/quarantine"

describe Cask::Quarantine, :cask do
  matcher :be_quarantined do
    match do |path|
      expect(
        described_class.detect(path),
      ).to be true
    end
  end

  describe "by default" do
    it "quarantines a nice fresh Cask" do
      Cask::Cmd::Install.run("local-transmission")

      cask = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("Transmission.app")).to be_quarantined
    end

    it "quarantines Cask fetches" do
      Cask::Cmd::Fetch.run("local-transmission")
      local_transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
      cached_location = Cask::Download.new(local_transmission).fetch

      expect(cached_location).to be_quarantined
    end

    it "quarantines Cask audits" do
      Cask::Cmd::Audit.run("local-transmission", "--download")

      local_transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
      cached_location = Cask::Download.new(local_transmission).fetch

      expect(cached_location).to be_quarantined
    end

    it "quarantines Cask installs even if the fetch was not" do
      Cask::Cmd::Fetch.run("local-transmission", "--no-quarantine")

      Cask::Cmd::Install.run("local-transmission")

      cask = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("Transmission.app")).to be_quarantined
    end

    it "quarantines dmg-based Casks" do
      Cask::Cmd::Install.run("container-dmg")

      cask = Cask::CaskLoader.load(cask_path("container-dmg"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).to be_quarantined
    end

    it "quarantines tar-gz-based Casks" do
      Cask::Cmd::Install.run("container-tar-gz")

      cask = Cask::CaskLoader.load(cask_path("container-tar-gz"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).to be_quarantined
    end

    it "quarantines xar-based Casks" do
      Cask::Cmd::Install.run("container-xar")

      cask = Cask::CaskLoader.load(cask_path("container-xar"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).to be_quarantined
    end

    it "quarantines pure bzip2-based Casks" do
      Cask::Cmd::Install.run("container-bzip2")

      cask = Cask::CaskLoader.load(cask_path("container-bzip2"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).to be_quarantined
    end

    it "quarantines pure gzip-based Casks" do
      Cask::Cmd::Install.run("container-gzip")

      cask = Cask::CaskLoader.load(cask_path("container-gzip"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).to be_quarantined
    end

    it "quarantines the pkg in naked-pkg-based Casks" do
      Cask::Cmd::Install.run("container-pkg")

      cask = Cask::CaskLoader.load(cask_path("container-pkg"))

      expect(cask).to be_installed

      expect(cask.staged_path/"container.pkg").to be_quarantined
    end

    it "quarantines a nested container" do
      Cask::Cmd::Install.run("nested-app")

      cask = Cask::CaskLoader.load(cask_path("nested-app"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("MyNestedApp.app")).to be_quarantined
    end
  end

  describe "when disabled" do
    it "does not quarantine even a nice, fresh Cask" do
      Cask::Cmd::Install.run("local-transmission", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("Transmission.app")).not_to be_quarantined
    end

    it "does not quarantine Cask fetches" do
      Cask::Cmd::Fetch.run("local-transmission", "--no-quarantine")
      local_transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
      cached_location = Cask::Download.new(local_transmission).fetch

      expect(cached_location).not_to be_quarantined
    end

    it "does not quarantine Cask audits" do
      Cask::Cmd::Audit.run("local-transmission", "--download", "--no-quarantine")

      local_transmission = Cask::CaskLoader.load(cask_path("local-transmission"))
      cached_location = Cask::Download.new(local_transmission).fetch

      expect(cached_location).not_to be_quarantined
    end

    it "does not quarantine Cask installs even if the fetch was" do
      Cask::Cmd::Fetch.run("local-transmission")

      Cask::Cmd::Install.run("local-transmission", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("local-transmission"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("Transmission.app")).not_to be_quarantined
    end

    it "does not quarantine dmg-based Casks" do
      Cask::Cmd::Install.run("container-dmg", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("container-dmg"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).not_to be_quarantined
    end

    it "does not quarantine tar-gz-based Casks" do
      Cask::Cmd::Install.run("container-tar-gz", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("container-tar-gz"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).not_to be_quarantined
    end

    it "does not quarantine xar-based Casks" do
      Cask::Cmd::Install.run("container-xar", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("container-xar"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).not_to be_quarantined
    end

    it "does not quarantine pure bzip2-based Casks" do
      Cask::Cmd::Install.run("container-bzip2", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("container-bzip2"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).not_to be_quarantined
    end

    it "does not quarantine pure gzip-based Casks" do
      Cask::Cmd::Install.run("container-gzip", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("container-gzip"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("container")).not_to be_quarantined
    end

    it "does not quarantine the pkg in naked-pkg-based Casks" do
      Cask::Cmd::Install.run("container-pkg", "--no-quarantine")

      naked_pkg = Cask::CaskLoader.load(cask_path("container-pkg"))

      expect(naked_pkg).to be_installed

      expect(
        Cask::Caskroom.path.join("container-pkg", naked_pkg.version, "container.pkg"),
      ).not_to be_quarantined
    end

    it "does not quarantine a nested container" do
      Cask::Cmd::Install.run("nested-app", "--no-quarantine")

      cask = Cask::CaskLoader.load(cask_path("nested-app"))

      expect(cask).to be_installed

      expect(cask.config.appdir.join("MyNestedApp.app")).not_to be_quarantined
    end
  end
end
