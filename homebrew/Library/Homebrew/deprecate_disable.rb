# typed: true
# frozen_string_literal: true

# Helper module for handling `disable!` and `deprecate!`.
#
# @api private
module DeprecateDisable
  module_function

  DEPRECATE_DISABLE_REASONS = {
    does_not_build:      "does not build",
    no_license:          "has no license",
    repo_archived:       "has an archived upstream repository",
    repo_removed:        "has a removed upstream repository",
    unmaintained:        "is not maintained upstream",
    unsupported:         "is not supported upstream",
    deprecated_upstream: "is deprecated upstream",
    versioned_formula:   "is a versioned formula",
  }.freeze

  def deprecate_disable_info(formula)
    return unless formula.deprecated? || formula.disabled?

    if formula.deprecated?
      type = :deprecated
      reason = formula.deprecation_reason
    else
      type = :disabled
      reason = formula.disable_reason
    end

    reason = DEPRECATE_DISABLE_REASONS[reason] if DEPRECATE_DISABLE_REASONS.key? reason

    [type, reason]
  end
end
