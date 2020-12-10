# typed: strict
# frozen_string_literal: true

require "hardware"
require "diagnostic"
require "extend/ENV/shared"
require "extend/ENV/std"
require "extend/ENV/super"

module Kernel
  extend T::Sig

  sig { params(env: T.nilable(String)).returns(T::Boolean) }
  def superenv?(env)
    return false if env == "std"

    !Superenv.bin.nil?
  end
  private :superenv?
end

module EnvActivation
  extend T::Sig

  sig { params(env: T.nilable(String)).void }
  def activate_extensions!(env: nil)
    if superenv?(env)
      extend(Superenv)
    else
      extend(Stdenv)
    end
  end

  sig do
    params(
      env:          T.nilable(String),
      cc:           T.nilable(String),
      build_bottle: T.nilable(T::Boolean),
      bottle_arch:  T.nilable(String),
      _block:       T.proc.returns(T.untyped),
    ).returns(T.untyped)
  end
  def with_build_environment(env: nil, cc: nil, build_bottle: false, bottle_arch: nil, &_block)
    old_env = to_hash.dup
    tmp_env = to_hash.dup.extend(EnvActivation)
    T.cast(tmp_env, EnvActivation).activate_extensions!(env: env)
    T.cast(tmp_env, T.any(Superenv, Stdenv))
     .setup_build_environment(cc: cc, build_bottle: build_bottle, bottle_arch: bottle_arch)
    replace(tmp_env)

    begin
      yield
    ensure
      replace(old_env)
    end
  end

  sig { params(key: T.any(String, Symbol)).returns(T::Boolean) }
  def sensitive?(key)
    key.match?(/(cookie|key|token|password)/i)
  end

  sig { returns(T::Hash[String, String]) }
  def sensitive_environment
    select { |key, _| sensitive?(key) }
  end

  sig { void }
  def clear_sensitive_environment!
    each_key { |key| delete key if sensitive?(key) }
  end
end

ENV.extend(EnvActivation)
