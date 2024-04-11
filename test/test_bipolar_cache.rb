# frozen_string_literal: true

require "test_helper"

class TestBipolarCache < Minitest::Test
  def setup
    @value = 42
    @cache = 0

    @example_procs = {
      actual: -> { @value },
      cached: -> { @cache },
      chance: ->(_v) { 1 },
      if: -> { true },
      rescue: ->(e) { e },
      update: ->(v) { @cache = v }
    }

    @bipolar_cache = BipolarCache
  end

  def test_that_it_has_a_version_number
    refute_nil ::BipolarCache::VERSION
  end

  def test_it_hits_cache_when_chance_is_one
    procs = @example_procs.merge({ chance: ->(_v) { 1 } })
    assert_equal 0, @bipolar_cache.read!(**procs)
  end

  def test_it_misses_and_updates_cache_when_chance_is_zero
    procs = @example_procs.merge({ chance: ->(_v) { 0 } })
    result = @bipolar_cache.read!(**procs)
    assert_equal 42, result
    assert_equal 42, @cache
  end

  def test_it_misses_cache_when_if_is_false_does_not_update
    procs = @example_procs.merge({ chance: ->(_v) { 1 }, if: -> { false } })
    result = @bipolar_cache.read!(**procs)
    assert_equal 42, result
    assert_equal 0, @cache
  end

  def test_it_updates_cache_when_chance_is_one
    procs = @example_procs.merge({ chance: ->(_v) { 1 } })
    result = @bipolar_cache.read!(**procs)
    assert_equal 0, result
    assert_equal 42, @value
    assert_equal 0, @cache
  end
end
