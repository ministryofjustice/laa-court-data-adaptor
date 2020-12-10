# typed: true
# frozen_string_literal: true

OFFICIAL_CASK_TAPS = %w[
  cask
  versions
].freeze

OFFICIAL_CMD_TAPS = {
  "homebrew/bundle"   => ["bundle"],
  "homebrew/test-bot" => ["test-bot"],
  "homebrew/services" => ["services"],
}.freeze

DEPRECATED_OFFICIAL_TAPS = %w[
  apache
  binary
  cask-eid
  completions
  devel-only
  dupes
  emacs
  fuse
  games
  gui
  head-only
  livecheck
  nginx
  php
  python
  science
  tex
  versions
  x11
].freeze
