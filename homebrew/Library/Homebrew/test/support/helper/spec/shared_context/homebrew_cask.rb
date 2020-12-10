# typed: false
# frozen_string_literal: true

require "cask/config"
require "cask/cache"

require "test/support/helper/cask/install_helper"
require "test/support/helper/cask/never_sudo_system_command"

module Cask
  class Config
    DEFAULT_DIRS_PATHNAMES = {
      appdir:               Pathname(TEST_TMPDIR)/"cask-appdir",
      prefpanedir:          Pathname(TEST_TMPDIR)/"cask-prefpanedir",
      qlplugindir:          Pathname(TEST_TMPDIR)/"cask-qlplugindir",
      mdimporterdir:        Pathname(TEST_TMPDIR)/"cask-mdimporter",
      dictionarydir:        Pathname(TEST_TMPDIR)/"cask-dictionarydir",
      fontdir:              Pathname(TEST_TMPDIR)/"cask-fontdir",
      colorpickerdir:       Pathname(TEST_TMPDIR)/"cask-colorpickerdir",
      servicedir:           Pathname(TEST_TMPDIR)/"cask-servicedir",
      input_methoddir:      Pathname(TEST_TMPDIR)/"cask-input_methoddir",
      internet_plugindir:   Pathname(TEST_TMPDIR)/"cask-internet_plugindir",
      audio_unit_plugindir: Pathname(TEST_TMPDIR)/"cask-audio_unit_plugindir",
      vst_plugindir:        Pathname(TEST_TMPDIR)/"cask-vst_plugindir",
      vst3_plugindir:       Pathname(TEST_TMPDIR)/"cask-vst3_plugindir",
      screen_saverdir:      Pathname(TEST_TMPDIR)/"cask-screen_saverdir",
    }.freeze

    remove_const :DEFAULT_DIRS
    DEFAULT_DIRS = DEFAULT_DIRS_PATHNAMES.transform_values(&:to_s).freeze
  end
end

RSpec.shared_context "Homebrew Cask", :needs_macos do
  around do |example|
    third_party_tap = Tap.fetch("third-party", "tap")

    begin
      Cask::Config::DEFAULT_DIRS_PATHNAMES.values.each(&:mkpath)

      Tap.default_cask_tap.tap do |tap|
        FileUtils.mkdir_p tap.path.dirname
        FileUtils.ln_sf TEST_FIXTURE_DIR.join("cask"), tap.path
      end

      third_party_tap.tap do |tap|
        FileUtils.mkdir_p tap.path.dirname
        FileUtils.ln_sf TEST_FIXTURE_DIR.join("third-party"), tap.path
      end

      example.run
    ensure
      FileUtils.rm_rf Cask::Config::DEFAULT_DIRS_PATHNAMES.values
      FileUtils.rm_rf [Cask::Config.new.binarydir, Cask::Caskroom.path, Cask::Cache.path]
      Tap.default_cask_tap.path.unlink
      third_party_tap.path.unlink
      FileUtils.rm_rf third_party_tap.path.parent
    end
  end
end

RSpec.configure do |config|
  config.include_context "Homebrew Cask", :cask
end
