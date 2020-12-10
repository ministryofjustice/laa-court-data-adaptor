# typed: false
# frozen_string_literal: true

require "cli/parser"
require "utils/github"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def pr_publish_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `pr-publish` [<options>] <pull_request> [<pull_request> ...]

        Publish bottles for a pull request with GitHub Actions.
        Requires write access to the repository.
      EOS
      switch "--autosquash",
             description: "If supported on the target tap, automatically reformat and reword commits "\
                          "in the pull request to our preferred format."
      flag   "--message=",
             depends_on:  "--autosquash",
             description: "Message to include when autosquashing revision bumps, deletions, and rebuilds."
      flag   "--tap=",
             description: "Target tap repository (default: `homebrew/core`)."
      flag   "--workflow=",
             description: "Target workflow filename (default: `publish-commit-bottles.yml`)."

      min_named 1
    end
  end

  def pr_publish
    args = pr_publish_args.parse

    tap = Tap.fetch(args.tap || CoreTap.instance.name)
    workflow = args.workflow || "publish-commit-bottles.yml"
    ref = "master"

    extra_args = []
    extra_args << "--autosquash" if args.autosquash?
    extra_args << "--message='#{args.message}'" if args.message.presence
    dispatch_args = extra_args.join " "

    args.named.uniq.each do |arg|
      arg = "#{tap.default_remote}/pull/#{arg}" if arg.to_i.positive?
      url_match = arg.match HOMEBREW_PULL_OR_COMMIT_URL_REGEX
      _, user, repo, issue = *url_match
      odie "Not a GitHub pull request: #{arg}" unless issue
      if args.tap.present? && !"#{user}/#{repo}".casecmp(tap.full_name).zero?
        odie "Pull request URL is for #{user}/#{repo} but --tap=#{tap.full_name}!"
      end

      ohai "Dispatching #{tap} pull request ##{issue}"
      GitHub.workflow_dispatch_event(user, repo, workflow, ref, pull_request: issue, args: dispatch_args)
    end
  end
end
