# typed: false
# frozen_string_literal: true

module Homebrew
  module Livecheck
    module Strategy
      # The {Bitbucket} strategy identifies versions of software at
      # bitbucket.org by checking a repository's available downloads.
      #
      # Bitbucket URLs generally take one of the following formats:
      #
      # * `https://bitbucket.org/example/example/get/1.2.3.tar.gz`
      # * `https://bitbucket.org/example/example/downloads/example-1.2.3.tar.gz`
      #
      # The `/get/` archive files are simply automated snapshots of the files
      # for a given tag. The `/downloads/` archive files are files that have
      # been uploaded instead.
      #
      # It's also possible for an archive to come from a repository's wiki,
      # like:
      # `https://bitbucket.org/example/example/wiki/downloads/example-1.2.3.zip`.
      # This scenario is handled by this strategy as well and the `path` in
      # this example would be `example/example/wiki` (instead of
      # `example/example` with the previous URLs).
      #
      # The default regex identifies versions in archive files found in `href`
      # attributes.
      #
      # @api public
      class Bitbucket
        # The `Regexp` used to determine if the strategy applies to the URL.
        URL_MATCH_REGEX = %r{bitbucket\.org(/[^/]+){4}\.\w+}i.freeze

        # Whether the strategy can be applied to the provided URL.
        #
        # @param url [String] the URL to match against
        # @return [Boolean]
        def self.match?(url)
          URL_MATCH_REGEX.match?(url)
        end

        # Generates a URL and regex (if one isn't provided) and passes them
        # to {PageMatch.find_versions} to identify versions in the content.
        #
        # @param url [String] the URL of the content to check
        # @param regex [Regexp] a regex used for matching versions in content
        # @return [Hash]
        def self.find_versions(url, regex = nil)
          %r{
            bitbucket\.org/
            (?<path>.+?)/ # The path leading up to the get or downloads part
            (?<dl_type>get|downloads)/ # An indicator of the file download type
            (?<prefix>(?:[^/]+?[_-])?) # Filename text before the version
            v?\d+(?:\.\d+)+ # The numeric version
            (?<suffix>[^/]+) # Filename text after the version
          }ix =~ url

          # Use `\.t` instead of specific tarball extensions (e.g. .tar.gz)
          suffix.sub!(/\.t(?:ar\..+|[a-z0-9]+)$/i, "\.t")

          # `/get/` archives are Git tag snapshots, so we need to check that tab
          # instead of the main `/downloads/` page
          page_url = if dl_type == "get"
            "https://bitbucket.org/#{path}/downloads/?tab=tags"
          else
            "https://bitbucket.org/#{path}/downloads/"
          end

          # Example regexes:
          # * `/href=.*?v?(\d+(?:\.\d+)+)\.t/i`
          # * `/href=.*?example-v?(\d+(?:\.\d+)+)\.t/i`
          regex ||= /href=.*?#{Regexp.escape(prefix)}v?(\d+(?:\.\d+)+)#{Regexp.escape(suffix)}/i

          Homebrew::Livecheck::Strategy::PageMatch.find_versions(page_url, regex)
        end
      end
    end
  end
end
