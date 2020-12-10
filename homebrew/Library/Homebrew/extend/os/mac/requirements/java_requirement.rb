# typed: false
# frozen_string_literal: true

class JavaRequirement < Requirement
  env do
    env_java_common
    env_oracle_jdk || env_apple
  end

  private

  undef possible_javas, oracle_java_os

  def possible_javas
    javas = []
    javas << Pathname.new(ENV["JAVA_HOME"])/"bin/java" if ENV["JAVA_HOME"]
    javas << java_home_cmd
    which_java = which("java")
    # /usr/bin/java is a stub on macOS
    javas << which_java if which_java.to_s != "/usr/bin/java"
    javas
  end

  def oracle_java_os
    :darwin
  end

  def java_home_cmd
    # TODO: disable for all macOS versions and Linux on next minor release
    #       but --version with ranges is broken on Big Sur today.
    if MacOS.version >= :big_sur && @version&.end_with?("+")
      odisabled %Q(depends_on java: "#{@version}"),
                'depends_on "openjdk@11", depends_on "openjdk@8" or depends_on "openjdk"'
    end
    odeprecated "depends_on :java",
                'depends_on "openjdk@11", depends_on "openjdk@8" or depends_on "openjdk"'

    return unless File.executable?("/usr/libexec/java_home")

    args = %w[--failfast]
    args << "--version" << @version.to_s if @version
    java_home = Utils.popen_read("/usr/libexec/java_home", *args).chomp
    return unless $CHILD_STATUS.success?

    Pathname.new(java_home)/"bin/java"
  end

  def env_apple
    ENV.append_to_cflags "-I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/"
  end
end
