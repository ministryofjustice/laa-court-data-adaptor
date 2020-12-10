# typed: false
# frozen_string_literal: true

# Silence compatibility warning.
begin
  old_verbosity = $VERBOSE
  $VERBOSE = nil
  require "parser/current"
ensure
  $VERBOSE = old_verbosity
end

require "extend/string"
require "rubocops/shared/helper_functions"

module RuboCop
  module Cop
    # Superclass for all formula cops.
    #
    # @api private
    class FormulaCop < Cop
      include RangeHelp
      include HelperFunctions

      attr_accessor :file_path

      @registry = Cop.registry

      # This method is called by RuboCop and is the main entry point.
      def on_class(node)
        @file_path = processed_source.buffer.name
        return unless file_path_allowed?
        return unless formula_class?(node)
        return unless respond_to?(:audit_formula)

        class_node, parent_class_node, @body = *node
        @formula_name = Pathname.new(@file_path).basename(".rb").to_s
        @tap_style_exceptions = nil
        audit_formula(node, class_node, parent_class_node, @body)
      end

      # Yields to block when there is a match.
      #
      # @param urls [Array] url/mirror method call nodes
      # @param regex [Regexp] pattern to match URLs
      def audit_urls(urls, regex)
        urls.each do |url_node|
          url_string_node = parameters(url_node).first
          url_string = string_content(url_string_node)
          match_object = regex_match_group(url_string_node, regex)
          next unless match_object

          offending_node(url_string_node.parent)
          yield match_object, url_string
        end
      end

      # Returns all string nodes among the descendants of given node.
      def find_strings(node)
        return [] if node.nil?
        return [node] if node.str_type?

        node.each_descendant(:str)
      end

      # Returns method_node matching method_name.
      def find_node_method_by_name(node, method_name)
        return if node.nil?

        node.each_child_node(:send) do |method_node|
          next unless method_node.method_name == method_name

          @offensive_node = method_node
          @offense_source_range = method_node.source_range
          return method_node
        end
        # If not found then, parent node becomes the offensive node
        @offensive_node = node.parent
        @offense_source_range = node.parent.source_range
        nil
      end

      # Sets the given node as the offending node when required in custom cops.
      def offending_node(node)
        @offensive_node = node
        @offense_source_range = node.source_range
      end

      # Returns an array of method call nodes matching method_name inside node with depth first order (child nodes).
      def find_method_calls_by_name(node, method_name)
        return if node.nil?

        node.each_child_node(:send).select { |method_node| method_name == method_node.method_name }
      end

      # Returns an array of method call nodes matching method_name in every descendant of node.
      # Returns every method call if no method_name is passed.
      def find_every_method_call_by_name(node, method_name = nil)
        return if node.nil?

        node.each_descendant(:send).select do |method_node|
          method_name.nil? ||
            method_name == method_node.method_name
        end
      end

      # Returns array of function call nodes matching func_name in every descendant of node.
      #
      # - matches function call: `foo(*args, **kwargs)`
      # - does not match method calls: `foo.bar(*args, **kwargs)`
      # - returns every function call if no func_name is passed
      def find_every_func_call_by_name(node, func_name = nil)
        return if node.nil?

        node.each_descendant(:send).select do |func_node|
          func_node.receiver.nil? && (func_name.nil? || func_name == func_node.method_name)
        end
      end

      # Given a method_name and arguments, yields to a block with
      # matching method passed as a parameter to the block.
      def find_method_with_args(node, method_name, *args)
        methods = find_every_method_call_by_name(node, method_name)
        methods.each do |method|
          next unless parameters_passed?(method, *args)
          return true unless block_given?

          yield method
        end
      end

      # Matches a method with a receiver. Yields to a block with matching method node.
      #
      # @example to match `Formula.factory(name)`
      #   find_instance_method_call(node, "Formula", :factory)
      # @example to match `build.head?`
      #   find_instance_method_call(node, :build, :head?)
      def find_instance_method_call(node, instance, method_name)
        methods = find_every_method_call_by_name(node, method_name)
        methods.each do |method|
          next if method.receiver.nil?
          next if method.receiver.const_name != instance &&
                  !(method.receiver.send_type? && method.receiver.method_name == instance)

          @offense_source_range = method.source_range
          @offensive_node = method
          return true unless block_given?

          yield method
        end
      end

      # Matches receiver part of method. Yields to a block with parent node of receiver.
      #
      # @example to match `ARGV.<whatever>()`
      #   find_instance_call(node, "ARGV")
      def find_instance_call(node, name)
        node.each_descendant(:send) do |method_node|
          next if method_node.receiver.nil?
          next if method_node.receiver.const_name != name &&
                  !(method_node.receiver.send_type? && method_node.receiver.method_name == name)

          @offense_source_range = method_node.receiver.source_range
          @offensive_node = method_node.receiver
          return true unless block_given?

          yield method_node
        end
      end

      # Returns nil if does not depend on dependency_name.
      #
      # @param dependency_name dependency's name
      def depends_on?(dependency_name, *types)
        types = [:any] if types.empty?
        dependency_nodes = find_every_method_call_by_name(@body, :depends_on)
        idx = dependency_nodes.index do |n|
          types.any? { |type| depends_on_name_type?(n, dependency_name, type) }
        end
        return if idx.nil?

        @offense_source_range = dependency_nodes[idx].source_range
        @offensive_node = dependency_nodes[idx]
      end

      # Returns true if given dependency name and dependency type exist in given dependency method call node.
      # TODO: Add case where key of hash is an array
      def depends_on_name_type?(node, name = nil, type = :required)
        name_match = if name
          false
        else
          true # Match only by type when name is nil
        end

        case type
        when :required
          type_match = required_dependency?(node)
          name_match ||= required_dependency_name?(node, name) if type_match
        when :build, :test, :optional, :recommended
          type_match = dependency_type_hash_match?(node, type)
          name_match ||= dependency_name_hash_match?(node, name) if type_match
        when :any
          type_match = true
          name_match ||= required_dependency_name?(node, name)
          name_match ||= dependency_name_hash_match?(node, name)
        else
          type_match = false
        end

        if type_match || name_match
          @offensive_node = node
          @offense_source_range = node.source_range
        end
        type_match && name_match
      end

      # Find CONSTANTs in the source.
      # If block given, yield matching nodes.
      def find_const(node, const_name)
        return if node.nil?

        node.each_descendant(:const) do |const_node|
          next unless const_node.const_name == const_name

          @offensive_node = const_node
          @offense_source_range = const_node.source_range
          yield const_node if block_given?
          return true
        end
        nil
      end

      def_node_search :required_dependency?, <<~EOS
        (send nil? :depends_on ({str sym} _))
      EOS

      def_node_search :required_dependency_name?, <<~EOS
        (send nil? :depends_on ({str sym} %1))
      EOS

      def_node_search :dependency_type_hash_match?, <<~EOS
        (hash (pair ({str sym} _) ({str sym} %1)))
      EOS

      def_node_search :dependency_name_hash_match?, <<~EOS
        (hash (pair ({str sym} %1) (...)))
      EOS

      # To compare node with appropriate Ruby variable.
      def node_equals?(node, var)
        node == Parser::CurrentRuby.parse(var.inspect)
      end

      # Returns a block named block_name inside node.
      def find_block(node, block_name)
        return if node.nil?

        node.each_child_node(:block) do |block_node|
          next if block_node.method_name != block_name

          @offensive_node = block_node
          @offense_source_range = block_node.source_range
          return block_node
        end
        # If not found then, parent node becomes the offensive node
        @offensive_node = node.parent
        @offense_source_range = node.parent.source_range
        nil
      end

      # Returns an array of block nodes named block_name inside node.
      def find_blocks(node, block_name)
        return if node.nil?

        node.each_child_node(:block).select { |block_node| block_name == block_node.method_name }
      end

      # Returns an array of block nodes of any depth below node in AST.
      # If a block is given then yields matching block node to the block!
      def find_all_blocks(node, block_name)
        return if node.nil?

        blocks = node.each_descendant(:block).select { |block_node| block_name == block_node.method_name }
        return blocks unless block_given?

        blocks.each do |block_node|
          offending_node(block_node)
          yield block_node
        end
      end

      # Returns a method definition node with method_name.
      # Returns first method def if method_name is nil.
      def find_method_def(node, method_name = nil)
        return if node.nil?

        node.each_child_node(:def) do |def_node|
          def_method_name = method_name(def_node)
          next unless method_name == def_method_name || method_name.nil?

          @offensive_node = def_node
          @offense_source_range = def_node.source_range
          return def_node
        end
        return if node.parent.nil?

        # If not found then, parent node becomes the offensive node
        @offensive_node = node.parent
        @offense_source_range = node.parent.source_range
        nil
      end

      # Check if a method is called inside a block.
      def method_called_in_block?(node, method_name)
        block_body = node.children[2]
        block_body.each_child_node(:send) do |call_node|
          next unless call_node.method_name == method_name

          @offensive_node = call_node
          @offense_source_range = call_node.source_range
          return true
        end
        false
      end

      # Check if method_name is called among the direct children nodes in the given node.
      # Check if the node itself is the method.
      def method_called?(node, method_name)
        if node.send_type? && node.method_name == method_name
          offending_node(node)
          return true
        end
        node.each_child_node(:send) do |call_node|
          next unless call_node.method_name == method_name

          offending_node(call_node)
          return true
        end
        false
      end

      # Check if method_name is called among every descendant node of given node.
      def method_called_ever?(node, method_name)
        node.each_descendant(:send) do |call_node|
          next unless call_node.method_name == method_name

          @offensive_node = call_node
          @offense_source_range = call_node.source_range
          return true
        end
        false
      end

      # Checks for precedence; returns the first pair of precedence-violating nodes.
      def check_precedence(first_nodes, next_nodes)
        next_nodes.each do |each_next_node|
          first_nodes.each do |each_first_node|
            return [each_first_node, each_next_node] if component_precedes?(each_first_node, each_next_node)
          end
        end
        nil
      end

      # If first node does not precede next_node, sets appropriate instance variables for reporting.
      def component_precedes?(first_node, next_node)
        return false if line_number(first_node) < line_number(next_node)

        @offense_source_range = first_node.source_range
        @offensive_node = first_node
        true
      end

      # Check if negation is present in the given node.
      def expression_negated?(node)
        return false unless node.parent&.send_type?
        return false unless node.parent.method_name.equal?(:!)

        offending_node(node.parent)
      end

      # Return all the caveats' string nodes in an array.
      def caveats_strings
        find_strings(find_method_def(@body, :caveats))
      end

      # Returns the array of arguments of the method_node.
      def parameters(method_node)
        method_node.arguments if method_node.send_type? || method_node.block_type?
      end

      # Returns true if the given parameters are present in method call
      # and sets the method call as the offending node.
      # Params can be string, symbol, array, hash, matching regex.
      def parameters_passed?(method_node, *params)
        method_params = parameters(method_node)
        @offensive_node = method_node
        @offense_source_range = method_node.source_range
        params.all? do |given_param|
          method_params.any? do |method_param|
            if given_param.instance_of?(Regexp)
              regex_match_group(method_param, given_param)
            else
              node_equals?(method_param, given_param)
            end
          end
        end
      end

      # Returns the sha256 str node given a sha256 call node.
      def get_checksum_node(call)
        return if parameters(call).empty? || parameters(call).nil?

        if parameters(call).first.str_type?
          parameters(call).first
        # sha256 is passed as a key-value pair in bottle blocks
        elsif parameters(call).first.hash_type?
          parameters(call).first.keys.first
        end
      end

      # Yields to a block with comment text as parameter.
      def audit_comments
        @processed_source.comments.each do |comment_node|
          @offensive_node = comment_node
          @offense_source_range = :expression
          yield comment_node.text
        end
      end

      # Returns the ending position of the node in source code.
      def end_column(node)
        node.source_range.end_pos
      end

      # Returns the class node's name, or nil if not a class node.
      def class_name(node)
        @offensive_node = node
        @offense_source_range = node.source_range
        node.const_name
      end

      # Returns the method name for a def node.
      def method_name(node)
        node.children[0] if node.def_type?
      end

      # Returns the node size in the source code.
      def size(node)
        node.source_range.size
      end

      # Returns the block length of the block node.
      def block_size(block)
        block.loc.end.line - block.loc.begin.line
      end

      # Returns true if the formula is versioned.
      def versioned_formula?
        @formula_name.include?("@")
      end

      # Returns printable component name.
      def format_component(component_node)
        return component_node.method_name if component_node.send_type? || component_node.block_type?

        method_name(component_node) if component_node.def_type?
      end

      # Returns the formula tap.
      def formula_tap
        return unless match_obj = @file_path.match(%r{/(homebrew-\w+)/})

        match_obj[1]
      end

      # Returns whether the given formula exists in the given style exception list.
      # Defaults to the current formula being checked.
      def tap_style_exception?(list, formula = nil)
        if @tap_style_exceptions.nil? && !formula_tap.nil?
          @tap_style_exceptions = {}

          style_exceptions_dir = "#{File.dirname(File.dirname(@file_path))}/style_exceptions/*.json"
          Pathname.glob(style_exceptions_dir).each do |exception_file|
            list_name = exception_file.basename.to_s.chomp(".json").to_sym
            list_contents = begin
              JSON.parse exception_file.read
            rescue JSON::ParserError
              nil
            end
            next if list_contents.nil? || list_contents.count.zero?

            @tap_style_exceptions[list_name] = list_contents
          end
        end

        return false if @tap_style_exceptions.nil? || @tap_style_exceptions.count.zero?
        return false unless @tap_style_exceptions.key? list

        @tap_style_exceptions[list].include?(formula || @formula_name)
      end

      private

      def formula_class?(node)
        _, class_node, = *node
        class_names = %w[
          Formula
          GithubGistFormula
          ScriptFileFormula
          AmazonWebServicesFormula
        ]

        class_node && class_names.include?(string_content(class_node))
      end

      def file_path_allowed?
        paths_to_exclude = [%r{/Library/Homebrew/compat/},
                            %r{/Library/Homebrew/test/}]
        return true if @file_path.nil? # file_path is nil when source is directly passed to the cop, e.g. in specs

        @file_path !~ Regexp.union(paths_to_exclude)
      end
    end
  end
end
