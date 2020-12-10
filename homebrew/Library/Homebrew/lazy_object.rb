# typed: true
# frozen_string_literal: true

# An object which lazily evaluates its inner block only once a method is called on it.
#
# @api private
class LazyObject < Delegator
  def initialize(&callable)
    super(callable)
  end

  def __getobj__
    return @__delegate__ if defined?(@__delegate__)

    @__delegate__ = @__callable__.call
  end

  def __setobj__(callable)
    @__callable__ = callable
  end
end
