# typed: strict
# frozen_string_literal: true

require "rubocop"

require "rubocops/cask/constants/stanza"

require "rubocops/cask/ast/stanza"
require "rubocops/cask/ast/cask_header"
require "rubocops/cask/ast/cask_block"
require "rubocops/cask/extend/string"
require "rubocops/cask/extend/node"
require "rubocops/cask/mixin/cask_help"
require "rubocops/cask/mixin/on_homepage_stanza"
require "rubocops/cask/desc"
require "rubocops/cask/homepage_url_trailing_slash"
require "rubocops/cask/no_dsl_version"
require "rubocops/cask/stanza_order"
require "rubocops/cask/stanza_grouping"
