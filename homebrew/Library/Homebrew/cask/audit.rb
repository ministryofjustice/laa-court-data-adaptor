# typed: false
# frozen_string_literal: true

require "cask/denylist"
require "cask/download"
require "digest"
require "utils/curl"
require "utils/git"
require "utils/shared_audits"

module Cask
  # Audit a cask for various problems.
  #
  # @api private
  class Audit
    extend T::Sig

    extend Predicable

    attr_reader :cask, :download

    attr_predicate :appcast?, :new_cask?, :strict?, :online?, :token_conflicts?

    def initialize(cask, appcast: nil, download: nil, quarantine: nil,
                   token_conflicts: nil, online: nil, strict: nil,
                   new_cask: nil)

      # `new_cask` implies `online` and `strict`
      online = new_cask if online.nil?
      strict = new_cask if strict.nil?

      # `online` implies `appcast` and `download`
      appcast = online if appcast.nil?
      download = online if download.nil?

      # `new_cask` implies `token_conflicts`
      token_conflicts = new_cask if token_conflicts.nil?

      @cask = cask
      @appcast = appcast
      @download = Download.new(cask, quarantine: quarantine) if download
      @online = online
      @strict = strict
      @new_cask = new_cask
      @token_conflicts = token_conflicts
    end

    def run!
      check_denylist
      check_required_stanzas
      check_version
      check_sha256
      check_desc
      check_url
      check_unnecessary_verified
      check_missing_verified
      check_no_match
      check_generic_artifacts
      check_token_valid
      check_token_bad_words
      check_token_conflicts
      check_languages
      check_download
      check_https_availability
      check_single_pre_postflight
      check_single_uninstall_zap
      check_untrusted_pkg
      check_hosting_with_appcast
      check_latest_with_appcast
      check_latest_with_auto_updates
      check_stanza_requires_uninstall
      check_appcast_contains_version
      check_gitlab_repository
      check_gitlab_repository_archived
      check_gitlab_prerelease_version
      check_github_repository
      check_github_repository_archived
      check_github_prerelease_version
      check_bitbucket_repository
      self
    rescue => e
      odebug "#{e.message}\n#{e.backtrace.join("\n")}"
      add_error "exception while auditing #{cask}: #{e.message}"
      self
    end

    def errors
      @errors ||= []
    end

    def warnings
      @warnings ||= []
    end

    def add_error(message)
      errors << message
    end

    def add_warning(message)
      if strict?
        add_error message
      else
        warnings << message
      end
    end

    def errors?
      errors.any?
    end

    def warnings?
      warnings.any?
    end

    def result
      if errors?
        Formatter.error("failed")
      elsif warnings?
        Formatter.warning("warning")
      else
        Formatter.success("passed")
      end
    end

    sig { returns(String) }
    def summary
      summary = ["audit for #{cask}: #{result}"]

      errors.each do |error|
        summary << " #{Formatter.error("-")} #{error}"
      end

      warnings.each do |warning|
        summary << " #{Formatter.warning("-")} #{warning}"
      end

      summary.join("\n")
    end

    def success?
      !(errors? || warnings?)
    end

    private

    def check_untrusted_pkg
      odebug "Auditing pkg stanza: allow_untrusted"

      return if @cask.sourcefile_path.nil?

      tap = @cask.tap
      return if tap.nil?
      return if tap.user != "Homebrew"

      return unless cask.artifacts.any? { |k| k.is_a?(Artifact::Pkg) && k.stanza_options.key?(:allow_untrusted) }

      add_error "allow_untrusted is not permitted in official Homebrew Cask taps"
    end

    def check_stanza_requires_uninstall
      odebug "Auditing stanzas which require an uninstall"

      return if cask.artifacts.none? { |k| k.is_a?(Artifact::Pkg) || k.is_a?(Artifact::Installer) }
      return if cask.artifacts.any? { |k| k.is_a?(Artifact::Uninstall) }

      add_error "installer and pkg stanzas require an uninstall stanza"
    end

    def check_single_pre_postflight
      odebug "Auditing preflight and postflight stanzas"

      if cask.artifacts.count { |k| k.is_a?(Artifact::PreflightBlock) && k.directives.key?(:preflight) } > 1
        add_error "only a single preflight stanza is allowed"
      end

      count = cask.artifacts.count do |k|
        k.is_a?(Artifact::PostflightBlock) &&
          k.directives.key?(:postflight)
      end
      return unless count > 1

      add_error "only a single postflight stanza is allowed"
    end

    def check_single_uninstall_zap
      odebug "Auditing single uninstall_* and zap stanzas"

      if cask.artifacts.count { |k| k.is_a?(Artifact::Uninstall) } > 1
        add_error "only a single uninstall stanza is allowed"
      end

      count = cask.artifacts.count do |k|
        k.is_a?(Artifact::PreflightBlock) &&
          k.directives.key?(:uninstall_preflight)
      end

      add_error "only a single uninstall_preflight stanza is allowed" if count > 1

      count = cask.artifacts.count do |k|
        k.is_a?(Artifact::PostflightBlock) &&
          k.directives.key?(:uninstall_postflight)
      end

      add_error "only a single uninstall_postflight stanza is allowed" if count > 1

      return unless cask.artifacts.count { |k| k.is_a?(Artifact::Zap) } > 1

      add_error "only a single zap stanza is allowed"
    end

    def check_required_stanzas
      odebug "Auditing required stanzas"
      [:version, :sha256, :url, :homepage].each do |sym|
        add_error "a #{sym} stanza is required" unless cask.send(sym)
      end
      add_error "at least one name stanza is required" if cask.name.empty?
      # TODO: specific DSL knowledge should not be spread around in various files like this
      rejected_artifacts = [:uninstall, :zap]
      installable_artifacts = cask.artifacts.reject { |k| rejected_artifacts.include?(k) }
      add_error "at least one activatable artifact stanza is required" if installable_artifacts.empty?
    end

    def check_version
      return unless cask.version

      check_no_string_version_latest
      check_no_file_separator_in_version
    end

    def check_no_string_version_latest
      odebug "Verifying version :latest does not appear as a string ('latest')"
      return unless cask.version.raw_version == "latest"

      add_error "you should use version :latest instead of version 'latest'"
    end

    def check_no_file_separator_in_version
      odebug "Verifying version does not contain '#{File::SEPARATOR}'"
      return unless cask.version.raw_version.is_a?(String)
      return unless cask.version.raw_version.include?(File::SEPARATOR)

      add_error "version should not contain '#{File::SEPARATOR}'"
    end

    def check_sha256
      return unless cask.sha256

      check_sha256_no_check_if_latest
      check_sha256_actually_256
      check_sha256_invalid
    end

    def check_sha256_no_check_if_latest
      odebug "Verifying sha256 :no_check with version :latest"
      return unless cask.version.latest?
      return if cask.sha256 == :no_check

      add_error "you should use sha256 :no_check when version is :latest"
    end

    def check_sha256_actually_256
      odebug "Verifying sha256 string is a legal SHA-256 digest"
      return unless cask.sha256.is_a?(Checksum)
      return if cask.sha256.length == 64 && cask.sha256[/^[0-9a-f]+$/i]

      add_error "sha256 string must be of 64 hexadecimal characters"
    end

    def check_sha256_invalid
      odebug "Verifying sha256 is not a known invalid value"
      empty_sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      return unless cask.sha256 == empty_sha256

      add_error "cannot use the sha256 for an empty string: #{empty_sha256}"
    end

    def check_latest_with_appcast
      return unless cask.version.latest?
      return unless cask.appcast

      add_error "Casks with an appcast should not use version :latest"
    end

    def check_latest_with_auto_updates
      return unless cask.version.latest?
      return unless cask.auto_updates

      add_error "Casks with `version :latest` should not use `auto_updates`"
    end

    def check_hosting_with_appcast
      return if cask.appcast

      add_appcast = "please add an appcast. See https://github.com/Homebrew/homebrew-cask/blob/HEAD/doc/cask_language_reference/stanzas/appcast.md"

      case cask.url.to_s
      when %r{github.com/([^/]+)/([^/]+)/releases/download/(\S+)}
        return if cask.version.latest?

        add_error "Download uses GitHub releases, #{add_appcast}"
      when %r{sourceforge.net/(\S+)}
        return if cask.version.latest?

        add_error "Download is hosted on SourceForge, #{add_appcast}"
      when %r{dl.devmate.com/(\S+)}
        add_error "Download is hosted on DevMate, #{add_appcast}"
      when %r{rink.hockeyapp.net/(\S+)}
        add_error "Download is hosted on HockeyApp, #{add_appcast}"
      end
    end

    def check_desc
      return if cask.desc.present?

      add_warning "Cask should have a description. Please add a `desc` stanza."
    end

    def check_url
      return unless cask.url

      check_download_url_format
    end

    def check_download_url_format
      odebug "Auditing URL format"
      if bad_sourceforge_url?
        add_error "SourceForge URL format incorrect. See https://github.com/Homebrew/homebrew-cask/blob/HEAD/doc/cask_language_reference/stanzas/url.md#sourceforgeosdn-urls"
      elsif bad_osdn_url?
        add_error "OSDN URL format incorrect. See https://github.com/Homebrew/homebrew-cask/blob/HEAD/doc/cask_language_reference/stanzas/url.md#sourceforgeosdn-urls"
      end
    end

    def bad_url_format?(regex, valid_formats_array)
      return false unless cask.url.to_s.match?(regex)

      valid_formats_array.none? { |format| cask.url.to_s =~ format }
    end

    def bad_sourceforge_url?
      bad_url_format?(/sourceforge/,
                      [
                        %r{\Ahttps://sourceforge\.net/projects/[^/]+/files/latest/download\Z},
                        %r{\Ahttps://downloads\.sourceforge\.net/(?!(project|sourceforge)/)},
                      ])
    end

    def bad_osdn_url?
      bad_url_format?(/osd/, [%r{\Ahttps?://([^/]+.)?dl\.osdn\.jp/}])
    end

    def homepage
      URI(cask.homepage.to_s).host
    end

    def domain
      URI(cask.url.to_s).host
    end

    def url_match_homepage?
      host = cask.url.to_s.downcase
      host_uri = URI(host)
      host = if host.match?(/:\d/) && host_uri.port != 80
        "#{host_uri.host}:#{host_uri.port}"
      else
        host_uri.host
      end
      home = homepage.downcase
      if (split_host = host.split(".")).length >= 3
        host = split_host[-2..].join(".")
      end
      if (split_home = homepage.split(".")).length >= 3
        home = split_home[-2..].join(".")
      end
      host == home
    end

    def strip_url_scheme(url)
      url.sub(%r{^.*://(www\.)?}, "")
    end

    def url_from_verified
      cask.url.verified.sub(%r{^https?://}, "")
    end

    def verified_matches_url?
      strip_url_scheme(cask.url.to_s).start_with?(url_from_verified)
    end

    def verified_present?
      cask.url.verified.present?
    end

    def url_includes_file?
      cask.url.to_s.start_with?("file://")
    end

    def check_unnecessary_verified
      return unless verified_present?
      return unless url_match_homepage?
      return unless verified_matches_url?

      add_warning "The URL's #{domain} matches the homepage #{homepage}, " \
                  "the `verified` parameter of the `url` stanza is unnecessary. " \
                  "See https://github.com/Homebrew/homebrew-cask/blob/master/doc/cask_language_reference/stanzas/url.md#when-url-and-homepage-hostnames-differ-add-verified"
    end

    def check_missing_verified
      return if url_includes_file?
      return if url_match_homepage?
      return if verified_present?

      add_warning "#{domain} does not match #{homepage}, a `verified` parameter of the `url` has to be added. " \
                  " See https://github.com/Homebrew/homebrew-cask/blob/master/doc/cask_language_reference/stanzas/url.md#when-url-and-homepage-hostnames-differ-add-verified"
    end

    def check_no_match
      return if url_match_homepage?
      return unless verified_present?
      return if !url_match_homepage? && verified_matches_url?

      add_warning "#{url_from_verified} does not match #{strip_url_scheme(cask.url.to_s)}. " \
                  "See https://github.com/Homebrew/homebrew-cask/blob/master/doc/cask_language_reference/stanzas/url.md#when-url-and-homepage-hostnames-differ-add-verified"
    end

    def check_generic_artifacts
      cask.artifacts.select { |a| a.is_a?(Artifact::Artifact) }.each do |artifact|
        unless artifact.target.absolute?
          add_error "target must be absolute path for #{artifact.class.english_name} #{artifact.source}"
        end
      end
    end

    def check_languages
      @cask.languages.each do |language|
        Locale.parse(language)
      rescue Locale::ParserError
        add_error "Locale '#{language}' is invalid."
      end
    end

    def check_token_conflicts
      return unless token_conflicts?
      return unless core_formula_names.include?(cask.token)

      add_warning "possible duplicate, cask token conflicts with Homebrew core formula: #{core_formula_url}"
    end

    def check_token_valid
      add_error "cask token contains non-ascii characters" unless cask.token.ascii_only?
      add_error "cask token + should be replaced by -plus-" if cask.token.include? "+"
      add_error "cask token whitespace should be replaced by hyphens" if cask.token.include? " "
      add_error "cask token @ should be replaced by -at-" if cask.token.include? "@"
      add_error "cask token underscores should be replaced by hyphens" if cask.token.include? "_"
      add_error "cask token should not contain double hyphens" if cask.token.include? "--"

      if cask.token.match?(/[^a-z0-9\-]/)
        add_error "cask token should only contain lowercase alphanumeric characters and hyphens"
      end

      return unless cask.token.start_with?("-") || cask.token.end_with?("-")

      add_error "cask token should not have leading or trailing hyphens"
    end

    def check_token_bad_words
      return unless new_cask?

      token = cask.token

      add_error "cask token contains .app" if token.end_with? ".app"

      if /-(?<designation>alpha|beta|rc|release-candidate)$/ =~ cask.token &&
         cask.tap&.official? &&
         cask.tap != "homebrew/cask-versions"
        add_error "cask token contains version designation '#{designation}'"
      end

      add_warning "cask token mentions launcher" if token.end_with? "launcher"

      add_warning "cask token mentions desktop" if token.end_with? "desktop"

      add_warning "cask token mentions platform" if token.end_with? "mac", "osx", "macos"

      add_warning "cask token mentions architecture" if token.end_with? "x86", "32_bit", "x86_64", "64_bit"

      return unless token.end_with?("cocoa", "qt", "gtk", "wx", "java") && %w[cocoa qt gtk wx java].exclude?(token)

      add_warning "cask token mentions framework"
    end

    def core_tap
      @core_tap ||= CoreTap.instance
    end

    def core_formula_names
      core_tap.formula_names
    end

    sig { returns(String) }
    def core_formula_url
      "#{core_tap.default_remote}/blob/HEAD/Formula/#{cask.token}.rb"
    end

    def check_download
      return unless download && cask.url

      odebug "Auditing download"
      download.fetch
    rescue => e
      add_error "download not possible: #{e}"
    end

    def check_appcast_contains_version
      return unless appcast?
      return if cask.appcast.to_s.empty?
      return if cask.appcast.must_contain == :no_check

      appcast_stanza = cask.appcast.to_s
      appcast_contents, = begin
        curl_output("--compressed", "--user-agent", HOMEBREW_USER_AGENT_FAKE_SAFARI, "--location",
                    "--globoff", "--max-time", "5", appcast_stanza)
      rescue
        add_error "appcast at URL '#{appcast_stanza}' offline or looping"
        return
      end

      version_stanza = cask.version.to_s
      adjusted_version_stanza = cask.appcast.must_contain.presence || version_stanza.match(/^[[:alnum:].]+/)[0]
      return if appcast_contents.include? adjusted_version_stanza

      add_error "appcast at URL '#{appcast_stanza}' does not contain"\
                  " the version number '#{adjusted_version_stanza}':\n#{appcast_contents}"
    end

    def check_github_prerelease_version
      return if cask.tap == "homebrew/cask-versions"

      odebug "Auditing GitHub prerelease"
      user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*}) if @online
      return if user.nil?

      tag = SharedAudits.github_tag_from_url(cask.url)
      tag ||= cask.version
      error = SharedAudits.github_release(user, repo, tag, cask: cask)
      add_error error if error
    end

    def check_gitlab_prerelease_version
      return if cask.tap == "homebrew/cask-versions"

      user, repo = get_repo_data(%r{https?://gitlab\.com/([^/]+)/([^/]+)/?.*}) if @online
      return if user.nil?

      odebug "Auditing GitLab prerelease"

      tag = SharedAudits.gitlab_tag_from_url(cask.url)
      tag ||= cask.version
      error = SharedAudits.gitlab_release(user, repo, tag)
      add_error error if error
    end

    def check_github_repository_archived
      user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*}) if @online
      return if user.nil?

      odebug "Auditing GitHub repo archived"

      metadata = SharedAudits.github_repo_data(user, repo)
      return if metadata.nil?

      return unless metadata["archived"]

      message = "GitHub repo is archived"

      if cask.discontinued?
        add_warning message
      else
        add_error message
      end
    end

    def check_gitlab_repository_archived
      user, repo = get_repo_data(%r{https?://gitlab\.com/([^/]+)/([^/]+)/?.*}) if @online
      return if user.nil?

      odebug "Auditing GitLab repo archived"

      metadata = SharedAudits.gitlab_repo_data(user, repo)
      return if metadata.nil?

      return unless metadata["archived"]

      message = "GitLab repo is archived"

      if cask.discontinued?
        add_warning message
      else
        add_error message
      end
    end

    def check_github_repository
      return unless new_cask?

      user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*})
      return if user.nil?

      odebug "Auditing GitHub repo"

      error = SharedAudits.github(user, repo)
      add_error error if error
    end

    def check_gitlab_repository
      return unless new_cask?

      user, repo = get_repo_data(%r{https?://gitlab\.com/([^/]+)/([^/]+)/?.*})
      return if user.nil?

      odebug "Auditing GitLab repo"

      error = SharedAudits.gitlab(user, repo)
      add_error error if error
    end

    def check_bitbucket_repository
      return unless new_cask?

      user, repo = get_repo_data(%r{https?://bitbucket\.org/([^/]+)/([^/]+)/?.*})
      return if user.nil?

      odebug "Auditing Bitbucket repo"

      error = SharedAudits.bitbucket(user, repo)
      add_error error if error
    end

    def get_repo_data(regex)
      return unless online?

      _, user, repo = *regex.match(cask.url.to_s)
      _, user, repo = *regex.match(cask.homepage) unless user
      _, user, repo = *regex.match(cask.appcast.to_s) unless user
      return if !user || !repo

      repo.gsub!(/.git$/, "")

      [user, repo]
    end

    def check_denylist
      return unless cask.tap&.official?
      return unless reason = Denylist.reason(cask.token)

      add_error "#{cask.token} is not allowed: #{reason}"
    end

    def check_https_availability
      return unless download

      check_url_for_https_availability(cask.url, user_agents: [cask.url.user_agent]) if cask.url && !cask.url.using

      check_url_for_https_availability(cask.appcast, check_content: true) if cask.appcast && appcast?

      check_url_for_https_availability(cask.homepage, check_content: true, user_agents: [:browser]) if cask.homepage
    end

    def check_url_for_https_availability(url_to_check, **options)
      problem = curl_check_http_content(url_to_check.to_s, **options)
      add_error problem if problem
    end
  end
end
