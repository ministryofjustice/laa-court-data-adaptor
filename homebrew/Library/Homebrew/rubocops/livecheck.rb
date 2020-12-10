# typed: true
# frozen_string_literal: true

require "rubocops/extend/formula"

module RuboCop
  module Cop
    module FormulaAudit
      # This cop ensures that no other livecheck information is provided for
      # skipped formulae.
      #
      # @api private
      class LivecheckSkip < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first
          return if skip.blank?

          return if find_every_method_call_by_name(livecheck_node).length < 3

          offending_node(livecheck_node)
          problem "Skipped formulae must not contain other livecheck information."
        end

        def autocorrect(node)
          lambda do |corrector|
            skip = find_every_method_call_by_name(node, :skip).first
            skip = find_strings(skip).first
            skip = string_content(skip) if skip.present?
            corrector.replace(
              node.source_range,
              <<~EOS.strip,
                livecheck do
                    skip#{" \"#{skip}\"" if skip.present?}
                  end
              EOS
            )
          end
        end
      end

      # This cop ensures that a `url` is specified in the `livecheck` block.
      #
      # @api private
      class LivecheckUrlProvided < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first
          return if skip.present?

          livecheck_url = find_every_method_call_by_name(livecheck_node, :url).first
          return if livecheck_url.present?

          offending_node(livecheck_node)
          problem "A `url` must be provided to livecheck."
        end
      end

      # This cop ensures that a supported symbol (`head`, `stable, `homepage`)
      # is used when the livecheck `url` is identical to one of these formula URLs.
      #
      # @api private
      class LivecheckUrlSymbol < FormulaCop
        @offense = nil

        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
          return if skip.present?

          livecheck_url_node = find_every_method_call_by_name(livecheck_node, :url).first
          livecheck_url = find_strings(livecheck_url_node).first
          return if livecheck_url.blank?

          livecheck_url = string_content(livecheck_url)

          head = find_every_method_call_by_name(body_node, :head).first
          head_url = find_strings(head).first

          if head.present? && head_url.blank?
            head = find_every_method_call_by_name(head, :url).first
            head_url = find_strings(head).first
          end

          head_url = string_content(head_url) if head_url.present?

          stable = find_every_method_call_by_name(body_node, :url).first
          stable_url = find_strings(stable).first

          if stable_url.blank?
            stable = find_every_method_call_by_name(body_node, :stable).first
            stable = find_every_method_call_by_name(stable, :url).first
            stable_url = find_strings(stable).first
          end

          stable_url = string_content(stable_url) if stable_url.present?

          homepage = find_every_method_call_by_name(body_node, :homepage).first
          homepage_url = string_content(find_strings(homepage).first) if homepage.present?

          formula_urls = { head: head_url, stable: stable_url, homepage: homepage_url }.compact

          formula_urls.each do |symbol, url|
            next if url != livecheck_url && url != "#{livecheck_url}/" && "#{url}/" != livecheck_url

            offending_node(livecheck_url_node)
            @offense = symbol
            problem "Use `url :#{symbol}`"
            break
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, "url :#{@offense}")
            @offense = nil
          end
        end
      end

      # This cop ensures that the `regex` call in the `livecheck` block uses parentheses.
      #
      # @api private
      class LivecheckRegexParentheses < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
          return if skip.present?

          livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
          return if livecheck_regex_node.blank?

          return if parentheses?(livecheck_regex_node)

          offending_node(livecheck_regex_node)
          problem "The `regex` call should always use parentheses."
        end

        def autocorrect(node)
          lambda do |corrector|
            pattern = node.source.split[1..].join
            corrector.replace(node.source_range, "regex(#{pattern})")
          end
        end
      end

      # This cop ensures that the pattern provided to livecheck's `regex` uses `\.t` instead of
      # `\.tgz`, `\.tar.gz` and variants.
      #
      # @api private
      class LivecheckRegexExtension < FormulaCop
        TAR_PATTERN = /\\?\.t(ar|(g|l|x)z$|[bz2]{2,4}$)(\\?\.((g|l|x)z)|[bz2]{2,4}|Z)?$/i.freeze

        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
          return if skip.present?

          livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
          return if livecheck_regex_node.blank?

          regex_node = livecheck_regex_node.descendants.first
          pattern = string_content(find_strings(regex_node).first)
          match = pattern.match(TAR_PATTERN)
          return if match.blank?

          offending_node(regex_node)
          problem "Use `\\.t` instead of `#{match}`"
        end

        def autocorrect(node)
          lambda do |corrector|
            node = find_strings(node).first
            correct = node.source.gsub(TAR_PATTERN, "\\.t")
            corrector.replace(node.source_range, correct)
          end
        end
      end

      # This cop ensures that a `regex` is provided when `strategy :page_match` is specified
      # in the `livecheck` block.
      #
      # @api private
      class LivecheckRegexIfPageMatch < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
          return if skip.present?

          livecheck_strategy_node = find_every_method_call_by_name(livecheck_node, :strategy).first
          return if livecheck_strategy_node.blank?

          strategy = livecheck_strategy_node.descendants.first.source
          return if strategy != ":page_match"

          livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
          return if livecheck_regex_node.present?

          offending_node(livecheck_node)
          problem "A `regex` is required if `strategy :page_match` is present."
        end
      end

      # This cop ensures that the `regex` provided to livecheck is case-insensitive,
      # unless sensitivity is explicitly required for proper matching.
      #
      # @api private
      class LivecheckRegexCaseInsensitive < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          return if tap_style_exception? :regex_case_sensitive_allowlist

          livecheck_node = find_block(body_node, :livecheck)
          return if livecheck_node.blank?

          skip = find_every_method_call_by_name(livecheck_node, :skip).first.present?
          return if skip.present?

          livecheck_regex_node = find_every_method_call_by_name(livecheck_node, :regex).first
          return if livecheck_regex_node.blank?

          regex_node = livecheck_regex_node.descendants.first
          options_node = regex_node.regopt
          return if options_node.source.include?("i")

          offending_node(regex_node)
          problem "Regexes should be case-insensitive unless sensitivity is explicitly required for proper matching."
        end

        def autocorrect(node)
          lambda do |corrector|
            node = node.regopt
            corrector.replace(node.source_range, "i#{node.source}".chars.sort.join)
          end
        end
      end
    end
  end
end
