# typed: false
# frozen_string_literal: true

module Cask
  class DSL
    # Class corresponding to the `caveats` stanza.
    #
    # Each method should handle output, following the
    # convention of at least one trailing blank line so that the user
    # can distinguish separate caveats.
    #
    # The return value of the last method in the block is also sent
    # to the output by the caller, but that feature is only for the
    # convenience of cask authors.
    #
    # @api private
    class Caveats < Base
      extend Predicable

      attr_predicate :discontinued?

      def initialize(*args)
        super(*args)
        @built_in_caveats = {}
        @custom_caveats = []
        @discontinued = false
      end

      def self.caveat(name, &block)
        define_method(name) do |*args|
          key = [name, *args]
          text = instance_exec(*args, &block)
          @built_in_caveats[key] = text if text
          :built_in_caveat
        end
      end

      private_class_method :caveat

      def to_s
        (@custom_caveats + @built_in_caveats.values).join("\n")
      end

      # Override `puts` to collect caveats.
      def puts(*args)
        @custom_caveats += args
        :built_in_caveat
      end

      def eval_caveats(&block)
        result = instance_eval(&block)
        return unless result
        return if result == :built_in_caveat

        @custom_caveats << result.to_s.sub(/\s*\Z/, "\n")
      end

      caveat :kext do
        next if MacOS.version < :high_sierra

        <<~EOS
          #{@cask} requires a kernel extension to work.
          If the installation fails, retry after you enable it in:
            System Preferences → Security & Privacy → General

          For more information, refer to vendor documentation or this Apple Technical Note:
            #{Formatter.url("https://developer.apple.com/library/content/technotes/tn2459/_index.html")}
        EOS
      end

      caveat :unsigned_accessibility do |access = "Accessibility"|
        # access: the category in System Preferences -> Security & Privacy -> Privacy the app requires.

        <<~EOS
          #{@cask} is not signed and requires Accessibility access,
          so you will need to re-grant Accessibility access every time the app is updated.

          Enable or re-enable it in:
            System Preferences → Security & Privacy → Privacy -> #{access}
          To re-enable untick and retick #{@cask}.app.
        EOS
      end

      caveat :path_environment_variable do |path|
        <<~EOS
          To use #{@cask}, you may need to add the #{path} directory
          to your PATH environment variable, e.g. (for bash shell):
            export PATH=#{path}:"$PATH"
        EOS
      end

      caveat :zsh_path_helper do |path|
        <<~EOS
          To use #{@cask}, zsh users may need to add the following line to their
          ~/.zprofile.  (Among other effects, #{path} will be added to the
          PATH environment variable):
            eval `/usr/libexec/path_helper -s`
        EOS
      end

      caveat :files_in_usr_local do
        next unless HOMEBREW_PREFIX.to_s.downcase.start_with?("/usr/local")

        <<~EOS
          Cask #{@cask} installs files under /usr/local. The presence of such
          files can cause warnings when running `brew doctor`, which is considered
          to be a bug in Homebrew Cask.
        EOS
      end

      caveat :depends_on_java do |java_version = :any|
        if java_version == :any
          <<~EOS
            #{@cask} requires Java. You can install the latest version with:
              brew install --cask adoptopenjdk
          EOS
        elsif java_version.include?("11") || java_version.include?("+")
          <<~EOS
            #{@cask} requires Java #{java_version}. You can install the latest version with:
              brew install --cask adoptopenjdk
          EOS
        else
          <<~EOS
            #{@cask} requires Java #{java_version}. You can install it with:
              brew install --cask homebrew/cask-versions/adoptopenjdk#{java_version}
          EOS
        end
      end

      caveat :logout do
        <<~EOS
          You must log out and log back in for the installation of #{@cask} to take effect.
        EOS
      end

      caveat :reboot do
        <<~EOS
          You must reboot for the installation of #{@cask} to take effect.
        EOS
      end

      caveat :discontinued do
        @discontinued = true
        <<~EOS
          #{@cask} has been officially discontinued upstream.
          It may stop working correctly (or at all) in recent versions of macOS.
        EOS
      end

      caveat :license do |web_page|
        <<~EOS
          Installing #{@cask} means you have AGREED to the license at:
            #{Formatter.url(web_page.to_s)}
        EOS
      end

      caveat :free_license do |web_page|
        <<~EOS
          The vendor offers a free license for #{@cask} at:
            #{Formatter.url(web_page.to_s)}
        EOS
      end
    end
  end
end
