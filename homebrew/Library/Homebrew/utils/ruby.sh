export HOMEBREW_REQUIRED_RUBY_VERSION=2.6.3

test_ruby () {
  if [[ ! -x $1 ]]
  then
    return 1
  fi

  "$1" --enable-frozen-string-literal --disable=gems,did_you_mean,rubyopt \
    "$HOMEBREW_LIBRARY/Homebrew/utils/ruby_check_version_script.rb" \
    "$HOMEBREW_REQUIRED_RUBY_VERSION" 2>/dev/null
}

find_ruby() {
  if [[ -n "$HOMEBREW_MACOS" ]]
  then
    echo "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby"
  else
    IFS=$'\n' # Do word splitting on new lines only
    for ruby_exec in $(which -a ruby) $(PATH=$HOMEBREW_PATH which -a ruby)
    do
      if test_ruby "$ruby_exec"; then
        echo "$ruby_exec"
        break
      fi
    done
    IFS=$' \t\n' # Restore IFS to its default value
  fi
}

unusable_ruby() {
  if [[ -n "$HOMEBREW_MACOS_SYSTEM_RUBY_NEW_ENOUGH" ]]
  then
    return 1
  elif [[ -n "$HOMEBREW_RUBY_PATH" && -z "$HOMEBREW_FORCE_VENDOR_RUBY" ]] && test_ruby "$HOMEBREW_RUBY_PATH"
  then
    return 1
  else
    return 0
  fi
}

setup-ruby-path() {
  local vendor_dir
  local vendor_ruby_root
  local vendor_ruby_path
  local vendor_ruby_terminfo
  local vendor_ruby_latest_version
  local vendor_ruby_current_version
  # When bumping check if HOMEBREW_MACOS_SYSTEM_RUBY_NEW_ENOUGH (in brew.sh)
  # also needs to be changed.
  local ruby_exec
  local upgrade_fail
  local install_fail

  if [[ -n $HOMEBREW_MACOS ]]
  then
    upgrade_fail="Failed to upgrade Homebrew Portable Ruby!"
    install_fail="Failed to install Homebrew Portable Ruby (and your system version is too old)!"
  else
    local advice="
If there's no Homebrew Portable Ruby available for your processor:
- install Ruby $HOMEBREW_REQUIRED_RUBY_VERSION with your system package manager (or rbenv/ruby-build)
- make it first in your PATH
- try again
"
    upgrade_fail="Failed to upgrade Homebrew Portable Ruby!$advice"
    install_fail="Failed to install Homebrew Portable Ruby and cannot find another Ruby $HOMEBREW_REQUIRED_RUBY_VERSION!$advice"
  fi

  vendor_dir="$HOMEBREW_LIBRARY/Homebrew/vendor"
  vendor_ruby_root="$vendor_dir/portable-ruby/current"
  vendor_ruby_path="$vendor_ruby_root/bin/ruby"
  vendor_ruby_terminfo="$vendor_ruby_root/share/terminfo"
  vendor_ruby_latest_version=$(<"$vendor_dir/portable-ruby-version")
  vendor_ruby_current_version=$(readlink "$vendor_ruby_root")

  unset HOMEBREW_RUBY_PATH

  if [[ "$HOMEBREW_COMMAND" == "vendor-install" ]]
  then
    return 0
  fi

  if [[ -x "$vendor_ruby_path" ]]
  then
    HOMEBREW_RUBY_PATH="$vendor_ruby_path"
    TERMINFO_DIRS="$vendor_ruby_terminfo"
    if [[ $vendor_ruby_current_version != "$vendor_ruby_latest_version" ]]
    then
      brew vendor-install ruby || odie "$upgrade_fail"
    fi
  else
    HOMEBREW_RUBY_PATH=$(find_ruby)
    if [[ -z "$HOMEBREW_RUBY_PATH" || -n "$HOMEBREW_FORCE_VENDOR_RUBY" ]] || unusable_ruby
    then
      brew vendor-install ruby || odie "$install_fail"
      HOMEBREW_RUBY_PATH="$vendor_ruby_path"
      TERMINFO_DIRS="$vendor_ruby_terminfo"
    fi
  fi

  export HOMEBREW_RUBY_PATH
  [[ -n "$HOMEBREW_LINUX" && -n "$TERMINFO_DIRS" ]] && export TERMINFO_DIRS
}
