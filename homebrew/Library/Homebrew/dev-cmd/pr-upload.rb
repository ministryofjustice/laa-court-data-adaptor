# typed: false
# frozen_string_literal: true

require "cli/parser"
require "bintray"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def pr_upload_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `pr-upload` [<options>]

        Apply the bottle commit and publish bottles to Bintray or GitHub Releases.
      EOS
      switch "--no-publish",
             description: "Apply the bottle commit and upload the bottles, but don't publish them."
      switch "--keep-old",
             description: "If the formula specifies a rebuild version, " \
                          "attempt to preserve its value in the generated DSL."
      switch "-n", "--dry-run",
             description: "Print what would be done rather than doing it."
      switch "--no-commit",
             description: "Do not generate a new commit before uploading."
      switch "--warn-on-upload-failure",
             description: "Warn instead of raising an error if the bottle upload fails. "\
                          "Useful for repairing bottle uploads that previously failed."
      flag   "--bintray-org=",
             description: "Upload to the specified Bintray organisation (default: `homebrew`)."
      flag   "--root-url=",
             description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
    end
  end

  def check_bottled_formulae(bottles_hash)
    bottles_hash.each do |name, bottle_hash|
      formula_path = HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]
      formula_version = Formulary.factory(formula_path).pkg_version
      bottle_version = PkgVersion.parse bottle_hash["formula"]["pkg_version"]
      next if formula_version == bottle_version

      odie "Bottles are for #{name} #{bottle_version} but formula is version #{formula_version}!"
    end
  end

  def github_releases?(bottles_hash)
    @github_releases ||= bottles_hash.values.all? do |bottle_hash|
      root_url = bottle_hash["bottle"]["root_url"]
      url_match = root_url.match HOMEBREW_RELEASES_URL_REGEX
      _, _, _, tag = *url_match

      tag
    end
  end

  def pr_upload
    args = pr_upload_args.parse

    json_files = Dir["*.json"]
    odie "No JSON files found in the current working directory" if json_files.empty?

    bottles_hash = json_files.reduce({}) do |hash, json_file|
      hash.deep_merge(JSON.parse(IO.read(json_file)))
    end

    bottle_args = ["bottle", "--merge", "--write"]
    bottle_args << "--verbose" if args.verbose?
    bottle_args << "--debug" if args.debug?
    bottle_args << "--keep-old" if args.keep_old?
    bottle_args << "--root-url=#{args.root_url}" if args.root_url
    bottle_args << "--no-commit" if args.no_commit?
    bottle_args += json_files

    if args.dry_run?
      service = if github_releases?(bottles_hash)
        "GitHub Releases"
      else
        "Bintray"
      end
      puts "brew #{bottle_args.join " "}"
      puts "Upload bottles described by these JSON files to #{service}:\n  #{json_files.join("\n  ")}"
      return
    end

    check_bottled_formulae(bottles_hash)

    safe_system HOMEBREW_BREW_FILE, *bottle_args

    # Check the bottle commits did not break `brew audit`
    unless args.no_commit?
      audit_args = ["audit", "--skip-style"]
      audit_args << "--verbose" if args.verbose?
      audit_args << "--debug" if args.debug?
      audit_args += bottles_hash.keys
      safe_system HOMEBREW_BREW_FILE, *audit_args
    end

    if github_releases?(bottles_hash)
      # Handle uploading to GitHub Releases.
      bottles_hash.each_value do |bottle_hash|
        root_url = bottle_hash["bottle"]["root_url"]
        url_match = root_url.match HOMEBREW_RELEASES_URL_REGEX
        _, user, repo, tag = *url_match

        # Ensure a release is created.
        release = begin
          rel = GitHub.get_release user, repo, tag
          odebug "Existing GitHub release \"#{tag}\" found"
          rel
        rescue GitHub::HTTPNotFoundError
          odebug "Creating new GitHub release \"#{tag}\""
          GitHub.create_or_update_release user, repo, tag
        end

        # Upload bottles as release assets.
        bottle_hash["bottle"]["tags"].each_value do |tag_hash|
          remote_file = tag_hash["filename"]
          local_file = tag_hash["local_filename"]
          odebug "Uploading #{remote_file}"
          GitHub.upload_release_asset user, repo, release["id"], local_file: local_file, remote_file: remote_file
        end
      end
    else
      # Handle uploading to Bintray.
      bintray_org = args.bintray_org || "homebrew"
      bintray = Bintray.new(org: bintray_org)
      bintray.upload_bottles(bottles_hash,
                             publish_package: !args.no_publish?,
                             warn_on_error:   args.warn_on_upload_failure?)
    end
  end
end
