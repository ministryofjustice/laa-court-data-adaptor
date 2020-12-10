# typed: false
# frozen_string_literal: true

require "open-uri"

module Homebrew
  module Livecheck
    module Strategy
      # The {Xorg} strategy identifies versions of software at x.org by
      # checking directory listing pages.
      #
      # X.Org URLs take one of the following formats, among several others:
      #
      # * `https://www.x.org/archive/individual/app/example-1.2.3.tar.bz2`
      # * `https://www.x.org/archive/individual/font/example-1.2.3.tar.bz2`
      # * `https://www.x.org/archive/individual/lib/libexample-1.2.3.tar.bz2`
      # * `https://ftp.x.org/archive/individual/lib/libexample-1.2.3.tar.bz2`
      # * `https://www.x.org/pub/individual/doc/example-1.2.3.tar.gz`
      #
      # The notable differences between URLs are as follows:
      #
      # * `www.x.org` and `ftp.x.org` seem to be interchangeable (we prefer
      #   `www.x.org`).
      # * `/archive/` is the current top-level directory and `/pub/` will
      #   redirect to the same URL using `/archive/` instead. (The strategy
      #   handles this replacement to avoid the redirection.)
      # * The `/individual/` directory contains a number of directories (e.g.
      #   app, data, doc, driver, font, lib, etc.) which contain a number of
      #   different archive files.
      #
      # Since this strategy ends up checking the same directory listing pages
      # for multiple formulae, we've included a simple method of page caching.
      # This prevents livecheck from fetching the same page more than once and
      # also dramatically speeds up these checks. Eventually we hope to
      # implement a more sophisticated page cache that all strategies using
      # {PageMatch} can use (allowing us to simplify this strategy accordingly).
      #
      # The default regex identifies versions in archive files found in `href`
      # attributes.
      #
      # @api public
      class Xorg
        NICE_NAME = "X.Org"

        # The `Regexp` used to determine if the strategy applies to the URL.
        URL_MATCH_REGEX = %r{
          [/.]x\.org.*?/individual/|
          freedesktop\.org/(?:archive|dist|software)/
        }ix.freeze

        # Used to cache page content, so we don't fetch the same pages
        # repeatedly.
        @page_data = {}

        # Whether the strategy can be applied to the provided URL.
        #
        # @param url [String] the URL to match against
        # @return [Boolean]
        def self.match?(url)
          URL_MATCH_REGEX.match?(url)
        end

        # Generates a URL and regex (if one isn't provided) and checks the
        # content at the URL for new versions (using the regex for matching).
        #
        # The behavior in this method for matching text in the content using a
        # regex is copied and modified from the {PageMatch} strategy, so that
        # we can add some simple page caching. If this behavior is expanded to
        # apply to all strategies that use {PageMatch} to identify versions,
        # then this strategy can be brought in line with the others.
        #
        # @param url [String] the URL of the content to check
        # @param regex [Regexp] a regex used for matching versions in content
        # @return [Hash]
        def self.find_versions(url, regex)
          file_name = File.basename(url)

          /^(?<module_name>.+)-\d+/i =~ file_name

          # /pub/ URLs redirect to the same URL with /archive/, so we replace
          # it to avoid the redirection. Removing the filename from the end of
          # the URL gives us the relevant directory listing page.
          page_url = url.sub("x.org/pub/", "x.org/archive/").delete_suffix(file_name)

          regex ||= /href=.*?#{Regexp.escape(module_name)}[._-]v?(\d+(?:\.\d+)+)\.t/i

          match_data = { matches: {}, regex: regex, url: page_url }

          # Cache responses to avoid unnecessary duplicate fetches
          @page_data[page_url] = URI.parse(page_url).open.read unless @page_data.key?(page_url)

          matches = @page_data[page_url].scan(regex)
          matches.map(&:first).uniq.each do |match|
            match_data[:matches][match] = Version.new(match)
          end

          match_data
        end
      end
    end
  end
end
