# typed: false
# frozen_string_literal: true

# This script is loaded by formula_installer as a separate instance.
# Thrown exceptions are propagated back to the parent process over a pipe

old_trap = trap("INT") { exit! 130 }

require "global"
require "build_options"
require "cxxstdlib"
require "keg"
require "extend/ENV"
require "debrew"
require "fcntl"
require "socket"
require "cmd/install"

# A formula build.
#
# @api private
class Build
  attr_reader :formula, :deps, :reqs, :args

  def initialize(formula, options, args:)
    @formula = formula
    @formula.build = BuildOptions.new(options, formula.options)
    @args = args

    if args.ignore_deps?
      @deps = []
      @reqs = []
    else
      @deps = expand_deps
      @reqs = expand_reqs
    end
  end

  def post_superenv_hacks
    # Only allow Homebrew-approved directories into the PATH, unless
    # a formula opts-in to allowing the user's path.
    return unless formula.env.userpaths? || reqs.any? { |rq| rq.env.userpaths? }

    ENV.userpaths!
  end

  def effective_build_options_for(dependent)
    args  = dependent.build.used_options
    args |= Tab.for_formula(dependent).used_options
    BuildOptions.new(args, dependent.options)
  end

  def expand_reqs
    formula.recursive_requirements do |dependent, req|
      build = effective_build_options_for(dependent)
      if req.prune_from_option?(build) || req.prune_if_build_and_not_dependent?(dependent, formula) || req.test?
        Requirement.prune
      end
    end
  end

  def expand_deps
    formula.recursive_dependencies do |dependent, dep|
      build = effective_build_options_for(dependent)
      if dep.prune_from_option?(build) ||
         dep.prune_if_build_and_not_dependent?(dependent, formula) ||
         (dep.test? && !dep.build?)
        Dependency.prune
      elsif dep.build?
        Dependency.keep_but_prune_recursive_deps
      end
    end
  end

  def install
    formula_deps = deps.map(&:to_formula)
    keg_only_deps = formula_deps.select(&:keg_only?)
    run_time_deps = deps.reject(&:build?).map(&:to_formula)

    formula_deps.each do |dep|
      fixopt(dep) unless dep.opt_prefix.directory?
    end

    ENV.activate_extensions!(env: args.env)

    if superenv?(args.env)
      ENV.keg_only_deps = keg_only_deps
      ENV.deps = formula_deps
      ENV.run_time_deps = run_time_deps
      ENV.x11 = reqs.any? { |rq| rq.is_a?(X11Requirement) }
      ENV.setup_build_environment(
        formula:      formula,
        cc:           args.cc,
        build_bottle: args.build_bottle?,
        bottle_arch:  args.bottle_arch,
      )
      post_superenv_hacks
      reqs.each do |req|
        req.modify_build_environment(
          env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
        )
      end
      deps.each(&:modify_build_environment)
    else
      ENV.setup_build_environment(
        formula:      formula,
        cc:           args.cc,
        build_bottle: args.build_bottle?,
        bottle_arch:  args.bottle_arch,
      )
      reqs.each do |req|
        req.modify_build_environment(
          env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
        )
      end
      deps.each(&:modify_build_environment)

      keg_only_deps.each do |dep|
        ENV.prepend_path "PATH", dep.opt_bin.to_s
        ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_lib}/pkgconfig"
        ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_share}/pkgconfig"
        ENV.prepend_path "ACLOCAL_PATH", "#{dep.opt_share}/aclocal"
        ENV.prepend_path "CMAKE_PREFIX_PATH", dep.opt_prefix.to_s
        ENV.prepend "LDFLAGS", "-L#{dep.opt_lib}" if dep.opt_lib.directory?
        ENV.prepend "CPPFLAGS", "-I#{dep.opt_include}" if dep.opt_include.directory?
      end
    end

    new_env = {
      "TMPDIR" => HOMEBREW_TEMP,
      "TEMP"   => HOMEBREW_TEMP,
      "TMP"    => HOMEBREW_TEMP,
    }

    with_env(new_env) do
      formula.extend(Debrew::Formula) if args.debug?

      formula.update_head_version

      formula.brew(
        fetch:       false,
        keep_tmp:    args.keep_tmp?,
        interactive: args.interactive?,
      ) do
        # For head builds, HOMEBREW_FORMULA_PREFIX should include the commit,
        # which is not known until after the formula has been staged.
        ENV["HOMEBREW_FORMULA_PREFIX"] = formula.prefix

        formula.patch

        if args.git?
          system "git", "init"
          system "git", "add", "-A"
        end
        if args.interactive?
          ohai "Entering interactive mode"
          puts "Type `exit` to return and finalize the installation."
          puts "Install to this prefix: #{formula.prefix}"

          if args.git?
            puts "This directory is now a git repo. Make your changes and then use:"
            puts "  git diff | pbcopy"
            puts "to copy the diff to the clipboard."
          end

          interactive_shell(formula)
        else
          formula.prefix.mkpath

          (formula.logs/"00.options.out").write \
            "#{formula.full_name} #{formula.build.used_options.sort.join(" ")}".strip
          formula.install

          stdlibs = detect_stdlibs(ENV.compiler)
          tab = Tab.create(formula, ENV.compiler, stdlibs.first)
          tab.write

          # Find and link metafiles
          formula.prefix.install_metafiles formula.buildpath
          formula.prefix.install_metafiles formula.libexec if formula.libexec.exist?
        end
      end
    end
  end

  def detect_stdlibs(compiler)
    keg = Keg.new(formula.prefix)
    CxxStdlib.check_compatibility(formula, deps, keg, compiler)

    # The stdlib recorded in the install receipt is used during dependency
    # compatibility checks, so we only care about the stdlib that libraries
    # link against.
    keg.detect_cxx_stdlibs(skip_executables: true)
  end

  def fixopt(f)
    path = if f.linked_keg.directory? && f.linked_keg.symlink?
      f.linked_keg.resolved_path
    elsif f.prefix.directory?
      f.prefix
    elsif (kids = f.rack.children).size == 1 && kids.first.directory?
      kids.first
    else
      raise
    end
    Keg.new(path).optlink(verbose: args.verbose?)
  rescue
    raise "#{f.opt_prefix} not present or broken\nPlease reinstall #{f.full_name}. Sorry :("
  end
end

begin
  args = Homebrew.install_args.parse
  Context.current = args.context

  error_pipe = UNIXSocket.open(ENV.fetch("HOMEBREW_ERROR_PIPE"), &:recv_io)
  error_pipe.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)

  trap("INT", old_trap)

  formula = args.named.to_formulae.first
  options = Options.create(args.flags_only)
  build   = Build.new(formula, options, args: args)
  build.install
rescue Exception => e # rubocop:disable Lint/RescueException
  error_hash = JSON.parse e.to_json

  # Special case: need to recreate BuildErrors in full
  # for proper analytics reporting and error messages.
  # BuildErrors are specific to build processes and not other
  # children, which is why we create the necessary state here
  # and not in Utils.safe_fork.
  case error_hash["json_class"]
  when "BuildError"
    error_hash["cmd"] = e.cmd
    error_hash["args"] = e.args
    error_hash["env"] = e.env
  when "ErrorDuringExecution"
    error_hash["cmd"] = e.cmd
    error_hash["status"] = e.status.exitstatus
    error_hash["output"] = e.output
  end

  error_pipe.puts error_hash.to_json
  error_pipe.close
  exit! 1
end
