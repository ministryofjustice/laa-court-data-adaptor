# typed: false
# frozen_string_literal: true

require "tap"
require "cli/parser"

module Homebrew
  extend T::Sig

  module_function

  sig { returns(CLI::Parser) }
  def tap_new_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `tap-new` [<options>] <user>`/`<repo>

        Generate the template files for a new tap.
      EOS

      switch "--no-git",
             description: "Don't initialize a Git repository for the tap."
      flag   "--pull-label=",
             description: "Label name for pull requests ready to be pulled (default: `pr-pull`)."
      flag   "--branch=",
             description: "Initialize Git repository with the specified branch name (default: `main`)."

      conflicts "--no-git", "--branch"
      named 1
    end
  end

  def tap_new
    args = tap_new_args.parse

    label = args.pull_label || "pr-pull"
    branch = args.branch || "main"

    tap_name = args.named.first
    tap = Tap.fetch(tap_name)
    raise "Invalid tap name '#{tap_name}'" unless tap.path.to_s.match?(HOMEBREW_TAP_PATH_REGEX)

    titleized_user = tap.user.dup
    titleized_repo = tap.repo.dup
    titleized_user[0] = titleized_user[0].upcase
    titleized_repo[0] = titleized_repo[0].upcase

    (tap.path/"Formula").mkpath

    readme = <<~MARKDOWN
      # #{titleized_user} #{titleized_repo}

      ## How do I install these formulae?
      `brew install #{tap}/<formula>`

      Or `brew tap #{tap}` and then `brew install <formula>`.

      ## Documentation
      `brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
    MARKDOWN
    write_path(tap, "README.md", readme)

    actions_main = <<~YAML
      name: brew test-bot
      on:
        push:
          branches: #{branch}
        pull_request:
      jobs:
        test-bot:
          strategy:
            matrix:
              os: [ubuntu-latest, macOS-latest]
          runs-on: ${{ matrix.os }}
          steps:
            - name: Set up Homebrew
              id: set-up-homebrew
              uses: Homebrew/actions/setup-homebrew@master

            - name: Cache Homebrew Bundler RubyGems
              id: cache
              uses: actions/cache@v1
              with:
                path: ${{ steps.set-up-homebrew.outputs.gems-path }}
                key: ${{ runner.os }}-rubygems-${{ steps.set-up-homebrew.outputs.gems-hash }}
                restore-keys: ${{ runner.os }}-rubygems-

            - name: Install Homebrew Bundler RubyGems
              if: steps.cache.outputs.cache-hit != 'true'
              run: brew install-bundler-gems

            - run: brew test-bot --only-cleanup-before

            - run: brew test-bot --only-setup

            - run: brew test-bot --only-tap-syntax

            - run: brew test-bot --only-formulae
              if: github.event_name == 'pull_request'

            - name: Upload bottles as artifact
              if: always() && github.event_name == 'pull_request'
              uses: actions/upload-artifact@main
              with:
                name: bottles
                path: '*.bottle.*'
    YAML

    actions_publish = <<~YAML
      name: brew pr-pull
      on:
        pull_request_target:
          types:
            - labeled
      jobs:
        pr-pull:
          if: contains(github.event.pull_request.labels.*.name, '#{label}')
          runs-on: ubuntu-latest
          steps:
            - name: Set up Homebrew
              uses: Homebrew/actions/setup-homebrew@master

            - name: Set up git
              uses: Homebrew/actions/git-user-config@master

            - name: Pull bottles
              env:
                HOMEBREW_GITHUB_API_TOKEN: ${{ github.token }}
                PULL_REQUEST: ${{ github.event.pull_request.number }}
              run: brew pr-pull --debug --tap=$GITHUB_REPOSITORY $PULL_REQUEST

            - name: Push commits
              uses: Homebrew/actions/git-try-push@master
              with:
                token: ${{ github.token }}
                branch: #{branch}

            - name: Delete branch
              if: github.event.pull_request.head.repo.fork == false
              env:
                BRANCH: ${{ github.event.pull_request.head.ref }}
              run: git push --delete origin $BRANCH
    YAML

    (tap.path/".github/workflows").mkpath
    write_path(tap, ".github/workflows/tests.yml", actions_main)
    write_path(tap, ".github/workflows/publish.yml", actions_publish)

    unless args.no_git?
      cd tap.path do
        safe_system "git", "init"
        safe_system "git", "add", "--all"
        safe_system "git", "commit", "-m", "Create #{tap} tap"
        safe_system "git", "branch", "-m", branch
      end
    end

    ohai "Created #{tap}"
    puts <<~EOS
      #{tap.path}

      When a pull request making changes to a formula (or formulae) becomes green
      (all checks passed), then you can publish the built bottles.
      To do so, label your PR as `#{label}` and the workflow will be triggered.
    EOS
  end

  def write_path(tap, filename, content)
    path = tap.path/filename
    tap.path.mkpath
    raise "#{path} already exists" if path.exist?

    path.write content
  end
end
