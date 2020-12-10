# typed: true
# frozen_string_literal: true

require "open3"
require "ostruct"
require "plist"
require "shellwords"

require "extend/io"
require "extend/predicable"
require "extend/hash_validator"

# Class for running sub-processes and capturing their output and exit status.
#
# @api private
class SystemCommand
  extend T::Sig

  using HashValidator

  # Helper functions for calling {SystemCommand.run}.
  module Mixin
    def system_command(*args)
      T.unsafe(SystemCommand).run(*args)
    end

    def system_command!(*args)
      T.unsafe(SystemCommand).run!(*args)
    end
  end

  include Context
  extend Predicable

  attr_reader :pid

  def self.run(executable, **options)
    T.unsafe(self).new(executable, **options).run!
  end

  def self.run!(command, **options)
    T.unsafe(self).run(command, **options, must_succeed: true)
  end

  sig { returns(SystemCommand::Result) }
  def run!
    puts redact_secrets(command.shelljoin.gsub('\=', "="), @secrets) if verbose? || debug?

    @output = []

    each_output_line do |type, line|
      case type
      when :stdout
        $stdout << line if print_stdout?
        @output << [:stdout, line]
      when :stderr
        $stderr << line if print_stderr?
        @output << [:stderr, line]
      end
    end

    result = Result.new(command, @output, @status, secrets: @secrets)
    result.assert_success! if must_succeed?
    result
  end

  sig do
    params(
      executable:   T.any(String, Pathname),
      args:         T::Array[T.any(String, Integer, Float, URI::Generic)],
      sudo:         T::Boolean,
      env:          T::Hash[String, String],
      input:        T.any(String, T::Array[String]),
      must_succeed: T::Boolean,
      print_stdout: T::Boolean,
      print_stderr: T::Boolean,
      verbose:      T::Boolean,
      secrets:      T.any(String, T::Array[String]),
      chdir:        T.any(String, Pathname),
    ).void
  end
  def initialize(executable, args: [], sudo: false, env: {}, input: [], must_succeed: false,
                 print_stdout: false, print_stderr: true, verbose: false, secrets: [], chdir: T.unsafe(nil))
    require "extend/ENV"
    @executable = executable
    @args = args
    @sudo = sudo
    env.each_key do |name|
      next if /^[\w&&\D]\w*$/.match?(name)

      raise ArgumentError, "Invalid variable name: '#{name}'"
    end
    @env = env
    @input = Array(input)
    @must_succeed = must_succeed
    @print_stdout = print_stdout
    @print_stderr = print_stderr
    @verbose = verbose
    @secrets = (Array(secrets) + ENV.sensitive_environment.values).uniq
    @chdir = chdir
  end

  sig { returns(T::Array[String]) }
  def command
    [*sudo_prefix, *env_args, executable.to_s, *expanded_args]
  end

  private

  attr_reader :executable, :args, :input, :chdir, :env

  attr_predicate :sudo?, :print_stdout?, :print_stderr?, :must_succeed?

  sig { returns(T::Boolean) }
  def verbose?
    return super if @verbose.nil?

    @verbose
  end

  sig { returns(T::Array[String]) }
  def env_args
    set_variables = env.compact.map do |name, value|
      sanitized_name = Shellwords.escape(name)
      sanitized_value = Shellwords.escape(value)
      "#{sanitized_name}=#{sanitized_value}"
    end

    return [] if set_variables.empty?

    ["/usr/bin/env", *set_variables]
  end

  sig { returns(T::Array[String]) }
  def sudo_prefix
    return [] unless sudo?

    askpass_flags = ENV.key?("SUDO_ASKPASS") ? ["-A"] : []
    ["/usr/bin/sudo", *askpass_flags, "-E", "--"]
  end

  sig { returns(T::Array[String]) }
  def expanded_args
    @expanded_args ||= args.map do |arg|
      if arg.respond_to?(:to_path)
        File.absolute_path(arg)
      elsif arg.is_a?(Integer) || arg.is_a?(Float) || arg.is_a?(URI::Generic)
        arg.to_s
      else
        arg.to_str
      end
    end
  end

  def each_output_line(&b)
    executable, *args = command

    raw_stdin, raw_stdout, raw_stderr, raw_wait_thr =
      T.unsafe(Open3).popen3(env, [executable, executable], *args, **{ chdir: chdir }.compact)
    @pid = raw_wait_thr.pid

    write_input_to(raw_stdin)
    raw_stdin.close_write
    each_line_from [raw_stdout, raw_stderr], &b

    @status = raw_wait_thr.value
  rescue SystemCallError => e
    @status = $CHILD_STATUS
    @output << [:stderr, e.message]
  end

  def write_input_to(raw_stdin)
    input.each(&raw_stdin.method(:write))
  end

  def each_line_from(sources)
    loop do
      readable_sources, = IO.select(sources)

      readable_sources = T.must(readable_sources).reject(&:eof?)

      break if readable_sources.empty?

      readable_sources.each do |source|
        line = source.readline_nonblock || ""
        type = (source == sources[0]) ? :stdout : :stderr
        yield(type, line)
      rescue IO::WaitReadable, EOFError
        next
      end
    end

    sources.each(&:close_read)
  end

  # Result containing the output and exit status of a finished sub-process.
  class Result
    extend T::Sig

    include Context

    attr_accessor :command, :status, :exit_status

    sig do
      params(
        command: T::Array[String],
        output:  T::Array[[Symbol, String]],
        status:  Process::Status,
        secrets: T::Array[String],
      ).void
    end
    def initialize(command, output, status, secrets:)
      @command       = command
      @output        = output
      @status        = status
      @exit_status   = status.exitstatus
      @secrets       = secrets
    end

    sig { void }
    def assert_success!
      return if @status.success?

      raise ErrorDuringExecution.new(command, status: @status, output: @output, secrets: @secrets)
    end

    sig { returns(String) }
    def stdout
      @stdout ||= @output.select { |type,| type == :stdout }
                         .map { |_, line| line }
                         .join
    end

    sig { returns(String) }
    def stderr
      @stderr ||= @output.select { |type,| type == :stderr }
                         .map { |_, line| line }
                         .join
    end

    sig { returns(String) }
    def merged_output
      @merged_output ||= @output.map { |_, line| line }
                                .join
    end

    sig { returns(T::Boolean) }
    def success?
      return false if @exit_status.nil?

      @exit_status.zero?
    end

    sig { returns([String, String, Process::Status]) }
    def to_ary
      [stdout, stderr, status]
    end

    sig { returns(T.nilable(T.any(Array, Hash))) }
    def plist
      @plist ||= begin
        output = stdout

        output = output.sub(/\A(.*?)(\s*<\?\s*xml)/m) do
          warn_plist_garbage(T.must(Regexp.last_match(1)))
          Regexp.last_match(2)
        end

        output = output.sub(%r{(<\s*/\s*plist\s*>\s*)(.*?)\Z}m) do
          warn_plist_garbage(T.must(Regexp.last_match(2)))
          Regexp.last_match(1)
        end

        Plist.parse_xml(output)
      end
    end

    sig { params(garbage: String).void }
    def warn_plist_garbage(garbage)
      return unless verbose?
      return unless garbage.match?(/\S/)

      opoo "Received non-XML output from #{Formatter.identifier(command.first)}:"
      $stderr.puts garbage.strip
    end
    private :warn_plist_garbage
  end
end

# Make `system_command` available everywhere.
# FIXME: Include this explicitly only where it is needed.
include SystemCommand::Mixin # rubocop:disable Style/MixinUsage
