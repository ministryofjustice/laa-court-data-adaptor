# typed: true
# frozen_string_literal: true

module RuboCop
  module Cask
    # Constants available globally for use in all cask cops.
    module Constants
      STANZA_GROUPS = [
        [:version, :sha256],
        [:language],
        [:url, :appcast, :name, :desc, :homepage],
        [
          :auto_updates,
          :conflicts_with,
          :depends_on,
          :container,
        ],
        [
          :suite,
          :app,
          :pkg,
          :installer,
          :binary,
          :manpage,
          :colorpicker,
          :dictionary,
          :font,
          :input_method,
          :internet_plugin,
          :prefpane,
          :qlplugin,
          :mdimporter,
          :screen_saver,
          :service,
          :audio_unit_plugin,
          :vst_plugin,
          :vst3_plugin,
          :artifact,
          :stage_only,
        ],
        [:preflight],
        [:postflight],
        [:uninstall_preflight],
        [:uninstall_postflight],
        [:uninstall],
        [:zap],
        [:caveats],
      ].freeze

      STANZA_GROUP_HASH =
        STANZA_GROUPS.each_with_object({}) do |stanza_group, hash|
          stanza_group.each { |stanza| hash[stanza] = stanza_group }
        end.freeze

      STANZA_ORDER = STANZA_GROUPS.flatten.freeze
    end
  end
end
