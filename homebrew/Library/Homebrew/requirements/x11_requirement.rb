# typed: false
# frozen_string_literal: true

require "requirement"

# A requirement on X11.
#
# @api private
class X11Requirement < Requirement
  extend T::Sig

  include Comparable

  fatal true

  cask "xquartz"
  download "https://xquartz.macosforge.org"

  env { ENV.x11 }

  sig { returns(String) }
  def min_version
    "1.12.2"
  end

  sig { returns(String) }
  def min_xdpyinfo_version
    "1.3.0"
  end

  satisfy build_env: false do
    if which_xorg = which("Xorg")
      version = Utils.popen_read(which_xorg, "-version", err: :out)[/X Server (\d+\.\d+\.\d+)/, 1]
      next true if $CHILD_STATUS.success? && version && Version.new(version) >= min_version
    end

    if which_xdpyinfo = which("xdpyinfo")
      version = Utils.popen_read(which_xdpyinfo, "-version")[/^xdpyinfo (\d+\.\d+\.\d+)/, 1]
      next true if $CHILD_STATUS.success? && version && Version.new(version) >= min_xdpyinfo_version
    end

    false
  end

  sig { returns(String) }
  def message
    "X11 is required for this software, either Xorg #{min_version} or " \
    "xdpyinfo #{min_xdpyinfo_version}, or newer. #{super}"
  end

  def <=>(other)
    return unless other.is_a? X11Requirement

    0
  end

  sig { returns(String) }
  def inspect
    "#<#{self.class.name}: #{tags.inspect}>"
  end
end

require "extend/os/requirements/x11_requirement"
