# typed: true
# frozen_string_literal: true

require "rubocops/extend/formula"

module RuboCop
  module Cop
    module FormulaAudit
      # This cop checks for various problems in a formula's source code.
      #
      # @api private
      class Text < FormulaCop
        def audit_formula(node, _class_node, _parent_class_node, body_node)
          @full_source_content = source_buffer(node).source

          if match = @full_source_content.match(/^require ['"]formula['"]$/)
            @offensive_node = node
            @source_buf = source_buffer(node)
            @line_no = match.pre_match.count("\n") + 1
            @column = 0
            @length = match[0].length
            @offense_source_range = source_range(@source_buf, @line_no, @column, @length)
            problem "`#{match}` is now unnecessary"
          end

          if !find_node_method_by_name(body_node, :plist_options) &&
             find_method_def(body_node, :plist)
            problem "Please set plist_options when using a formula-defined plist."
          end

          if (depends_on?("openssl") || depends_on?("openssl@1.1")) && depends_on?("libressl")
            problem "Formulae should not depend on both OpenSSL and LibreSSL (even optionally)."
          end

          if formula_tap == "homebrew-core" && (depends_on?("veclibfort") || depends_on?("lapack"))
            problem "Formulae in homebrew/core should use OpenBLAS as the default serial linear algebra library."
          end

          if method_called_ever?(body_node, :virtualenv_create) ||
             method_called_ever?(body_node, :virtualenv_install_with_resources)
            find_method_with_args(body_node, :resource, "setuptools") do
              problem "Formulae using virtualenvs do not need a `setuptools` resource."
            end
          end

          unless method_called_ever?(body_node, :go_resource)
            # processed_source.ast is passed instead of body_node because `require` would be outside body_node
            find_method_with_args(processed_source.ast, :require, "language/go") do
              problem "require \"language/go\" is unnecessary unless using `go_resource`s"
            end
          end

          find_instance_method_call(body_node, "Formula", :factory) do
            problem "\"Formula.factory(name)\" is deprecated in favor of \"Formula[name]\""
          end

          find_every_method_call_by_name(body_node, :xcodebuild).each do |m|
            next if parameters_passed?(m, /SYMROOT=/)

            problem 'xcodebuild should be passed an explicit "SYMROOT"'
          end

          find_method_with_args(body_node, :system, "xcodebuild") do
            problem %q(use "xcodebuild *args" instead of "system 'xcodebuild', *args")
          end

          find_method_with_args(body_node, :system, "go", "get") do
            problem "Do not use `go get`. Please ask upstream to implement Go vendoring"
          end

          find_method_with_args(body_node, :system, "dep", "ensure") do |d|
            next if parameters_passed?(d, /vendor-only/)
            next if @formula_name == "goose" # needed in 2.3.0

            problem "use \"dep\", \"ensure\", \"-vendor-only\""
          end

          find_method_with_args(body_node, :system, "cargo", "build") do
            problem "use \"cargo\", \"install\", *std_cargo_args"
          end

          find_every_method_call_by_name(body_node, :system).each do |m|
            next unless parameters_passed?(m, /make && make/)

            offending_node(m)
            problem "Use separate `make` calls"
          end

          body_node.each_descendant(:dstr) do |dstr_node|
            dstr_node.each_descendant(:begin) do |interpolation_node|
              next unless interpolation_node.source.match?(/#\{\w+\s*\+\s*['"][^}]+\}/)

              offending_node(interpolation_node)
              problem "Do not concatenate paths in string interpolation"
            end
          end

          prefix_path(body_node) do |prefix_node, path|
            next unless match = path.match(%r{^(bin|include|libexec|lib|sbin|share|Frameworks)(?:/| |$)})

            offending_node(prefix_node)
            problem "Use `#{match[1].downcase}` instead of `prefix + \"#{match[1]}\"`"
          end
        end

        # Find: prefix + "foo"
        def_node_search :prefix_path, <<~EOS
          $(send (send nil? :prefix) :+ (str $_))
        EOS
      end
    end

    module FormulaAuditStrict
      # This cop contains stricter checks for various problems in a formula's source code.
      #
      # @api private
      class Text < FormulaCop
        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          find_method_with_args(body_node, :go_resource) do
            problem "`go_resource`s are deprecated. Please ask upstream to implement Go vendoring"
          end

          find_method_with_args(body_node, :env, :userpaths) do
            problem "`env :userpaths` in homebrew/core formulae is deprecated"
          end

          share_path_starts_with(body_node, @formula_name) do |share_node|
            offending_node(share_node)
            problem "Use `pkgshare` instead of `share/\"#{@formula_name}\"`"
          end

          interpolated_share_path_starts_with(body_node, "/#{@formula_name}") do |share_node|
            offending_node(share_node)
            problem "Use `\#{pkgshare}` instead of `\#{share}/#{@formula_name}`"
          end

          return unless formula_tap == "homebrew-core"

          find_method_with_args(body_node, :env, :std) do
            problem "`env :std` in homebrew/core formulae is deprecated"
          end
        end

        # Check whether value starts with the formula name and then a "/", " " or EOS.
        def path_starts_with?(path, starts_with)
          path.match?(%r{^#{Regexp.escape(starts_with)}(/| |$)})
        end

        # Find "#{share}/foo"
        def_node_search :interpolated_share_path_starts_with, <<~EOS
          $(dstr (begin (send nil? :share)) (str #path_starts_with?(%1)))
        EOS

        # Find share/"foo"
        def_node_search :share_path_starts_with, <<~EOS
          $(send (send nil? :share) :/ (str #path_starts_with?(%1)))
        EOS
      end
    end
  end
end
