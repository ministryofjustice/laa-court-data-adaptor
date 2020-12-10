# typed: false
# frozen_string_literal: true

require "open3"

module Utils
  # Helper function for interacting with `curl`.
  #
  # @api private
  module Curl
    module_function

    def curl_executable
      @curl ||= [
        ENV["HOMEBREW_CURL"],
        which("curl"),
        "/usr/bin/curl",
      ].compact.map { |c| Pathname(c) }.find(&:executable?)
      raise "no executable curl was found" unless @curl

      @curl
    end

    def curl_args(*extra_args, show_output: false, user_agent: :default)
      args = []

      # do not load .curlrc unless requested (must be the first argument)
      args << "--disable" unless Homebrew::EnvConfig.curlrc?

      args << "--globoff"

      args << "--show-error"

      args << "--user-agent" << case user_agent
      when :browser, :fake
        HOMEBREW_USER_AGENT_FAKE_SAFARI
      when :default
        HOMEBREW_USER_AGENT_CURL
      else
        user_agent
      end

      args << "--header" << "Accept-Language: en"

      unless show_output
        args << "--fail"
        args << "--progress-bar" unless Context.current.verbose?
        args << "--verbose" if Homebrew::EnvConfig.curl_verbose?
        args << "--silent" unless $stdout.tty?
      end

      args << "--retry" << Homebrew::EnvConfig.curl_retries

      args + extra_args
    end

    def curl_with_workarounds(
      *args, secrets: nil, print_stdout: nil, print_stderr: nil, verbose: nil, env: {}, **options
    )
      command_options = {
        secrets:      secrets,
        print_stdout: print_stdout,
        print_stderr: print_stderr,
        verbose:      verbose,
      }.compact

      # SSL_CERT_FILE can be incorrectly set by users or portable-ruby and screw
      # with SSL downloads so unset it here.
      result = system_command curl_executable,
                              args: curl_args(*args, **options),
                              env:  { "SSL_CERT_FILE" => nil }.merge(env),
                              **command_options

      if !result.success? && args.exclude?("--http1.1")
        # This is a workaround for https://github.com/curl/curl/issues/1618.
        if result.status.exitstatus == 56 # Unexpected EOF
          out = curl_output("-V").stdout

          # If `curl` doesn't support HTTP2, the exception is unrelated to this bug.
          return result unless out.include?("HTTP2")

          # The bug is fixed in `curl` >= 7.60.0.
          curl_version = out[/curl (\d+(\.\d+)+)/, 1]
          return result if Gem::Version.new(curl_version) >= Gem::Version.new("7.60.0")

          return curl_with_workarounds(*args, "--http1.1", **command_options, **options)
        end

        if result.status.exitstatus == 16 # Error in the HTTP2 framing layer
          return curl_with_workarounds(*args, "--http1.1", **command_options, **options)
        end
      end

      result
    end

    def curl(*args, print_stdout: true, **options)
      result = curl_with_workarounds(*args, print_stdout: print_stdout, **options)
      result.assert_success!
      result
    end

    def curl_download(*args, to: nil, partial: true, **options)
      destination = Pathname(to)
      destination.dirname.mkpath

      if partial
        range_stdout = curl_output("--location", "--range", "0-1",
                                   "--dump-header", "-",
                                   "--write-out", "%\{http_code}",
                                   "--output", "/dev/null", *args, **options).stdout
        headers, _, http_status = range_stdout.partition("\r\n\r\n")

        supports_partial_download = http_status.to_i == 206 # Partial Content
        if supports_partial_download &&
           destination.exist? &&
           destination.size == %r{^.*Content-Range: bytes \d+-\d+/(\d+)\r\n.*$}m.match(headers)&.[](1)&.to_i
          return # We've already downloaded all the bytes
        end
      else
        supports_partial_download = false
      end

      continue_at = if destination.exist? && supports_partial_download
        "-"
      else
        0
      end

      curl(
        "--location", "--remote-time", "--continue-at", continue_at.to_s, "--output", destination, *args, **options
      )
    end

    def curl_output(*args, **options)
      curl_with_workarounds(*args, print_stderr: false, show_output: true, **options)
    end

    # Check if a URL is protected by CloudFlare (e.g. badlion.net and jaxx.io).
    def url_protected_by_cloudflare?(details)
      [403, 503].include?(details[:status].to_i) &&
        details[:headers].match?(/^Set-Cookie: __cfduid=/i) &&
        details[:headers].match?(/^Server: cloudflare/i)
    end

    # Check if a URL is protected by Incapsula (e.g. corsair.com).
    def url_protected_by_incapsula?(details)
      details[:status].to_i == 403 &&
        details[:headers].match?(/^Set-Cookie: visid_incap_/i) &&
        details[:headers].match?(/^Set-Cookie: incap_ses_/i)
    end

    def curl_check_http_content(url, user_agents: [:default], check_content: false, strict: false)
      return unless url.start_with? "http"

      details = nil
      user_agent = nil
      hash_needed = url.start_with?("http:")
      user_agents.each do |ua|
        details = curl_http_content_headers_and_checksum(url, hash_needed: hash_needed, user_agent: ua)
        user_agent = ua
        break if http_status_ok?(details[:status])
      end

      unless details[:status]
        # Hack around https://github.com/Homebrew/brew/issues/3199
        return if MacOS.version == :el_capitan

        return "The URL #{url} is not reachable"
      end

      unless http_status_ok?(details[:status])
        return if url_protected_by_cloudflare?(details) || url_protected_by_incapsula?(details)

        return "The URL #{url} is not reachable (HTTP status code #{details[:status]})"
      end

      if url.start_with?("https://") && Homebrew::EnvConfig.no_insecure_redirect? &&
         !details[:final_url].start_with?("https://")
        return "The URL #{url} redirects back to HTTP"
      end

      return unless hash_needed

      secure_url = url.sub "http", "https"
      secure_details =
        curl_http_content_headers_and_checksum(secure_url, hash_needed: true, user_agent: user_agent)

      if !http_status_ok?(details[:status]) ||
         !http_status_ok?(secure_details[:status])
        return
      end

      etag_match = details[:etag] &&
                   details[:etag] == secure_details[:etag]
      content_length_match =
        details[:content_length] &&
        details[:content_length] == secure_details[:content_length]
      file_match = details[:file_hash] == secure_details[:file_hash]

      if (etag_match || content_length_match || file_match) &&
         secure_details[:final_url].start_with?("https://") &&
         url.start_with?("http://")
        return "The URL #{url} should use HTTPS rather than HTTP"
      end

      return unless check_content

      no_protocol_file_contents = %r{https?:\\?/\\?/}
      details[:file] = details[:file].gsub(no_protocol_file_contents, "/")
      secure_details[:file] = secure_details[:file].gsub(no_protocol_file_contents, "/")

      # Check for the same content after removing all protocols
      if (details[:file] == secure_details[:file]) &&
         secure_details[:final_url].start_with?("https://") &&
         url.start_with?("http://")
        return "The URL #{url} should use HTTPS rather than HTTP"
      end

      return unless strict

      # Same size, different content after normalization
      # (typical causes: Generated ID, Timestamp, Unix time)
      if details[:file].length == secure_details[:file].length
        return "The URL #{url} may be able to use HTTPS rather than HTTP. Please verify it in a browser."
      end

      lenratio = (100 * secure_details[:file].length / details[:file].length).to_i
      return unless (90..110).cover?(lenratio)

      "The URL #{url} may be able to use HTTPS rather than HTTP. Please verify it in a browser."
    end

    def curl_http_content_headers_and_checksum(url, hash_needed: false, user_agent: :default)
      file = Tempfile.new.tap(&:close)

      max_time = hash_needed ? "600" : "25"
      output, = curl_output(
        "--dump-header", "-", "--output", file.path, "--include", "--location",
        "--connect-timeout", "15", "--max-time", max_time, url,
        user_agent: user_agent
      )

      status_code = :unknown
      while status_code == :unknown || status_code.to_s.start_with?("3")
        headers, _, output = output.partition("\r\n\r\n")
        status_code = headers[%r{HTTP/.* (\d+)}, 1]
        location = headers[/^Location:\s*(.*)$/i, 1]
        final_url = location.chomp if location
      end

      output_hash = Digest::SHA256.file(file.path) if hash_needed

      final_url ||= url

      {
        url:            url,
        final_url:      final_url,
        status:         status_code,
        etag:           headers[%r{ETag: ([wW]/)?"(([^"]|\\")*)"}, 2],
        content_length: headers[/Content-Length: (\d+)/, 1],
        headers:        headers,
        file_hash:      output_hash,
        file:           output,
      }
    ensure
      file.unlink
    end

    def http_status_ok?(status)
      (100..299).cover?(status.to_i)
    end
  end
end

# FIXME: Include `Utils::Curl` explicitly everywhere it is used.
include Utils::Curl # rubocop:disable Style/MixinUsage
