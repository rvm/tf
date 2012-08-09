require 'minitest/autorun'
require 'plugins/tf/env_type_test'

class TestEnvTypeTest < MiniTest::Unit::TestCase
  def setup
    @test = TF::EnvTypeTest.new
  end
  def test_matches
    assert @test.matches?("env[TEST]?=array")
    assert @test.matches?("env[TEST]?=string")
    assert @test.matches?("env[TEST]?=nil")
    assert @test.matches?("env[TEST]?!=array")
    assert @test.matches?("env[TEST]?!=string")
    assert @test.matches?("env[TEST]?!=nil")
    assert ! @test.matches?("env[TEST]?=a")
    assert ! @test.matches?("env[OTHER]?!=")
    assert ! @test.matches?("aenv[TEST]?!=//")
  end

  def test_env_success_string
    result, msg = @test.execute "env[TEST]?=string", "", "", "", 0, {'TEST' => "test"}
    assert result
    assert_equal msg, "passed: env? TEST = string"
  end
  def test_env_fail_string
    result, msg = @test.execute "env[TEST]?=string", "", "", "", 0, {'TEST' => nil}
    assert !result
    assert_equal msg, "failed: env? TEST = string # was nil"
  end

  def test_env_success_array
    result, msg = @test.execute "env[TEST]?=array", "", "", "", 0, {'TEST' => {"1" => "test"} }
    assert result
    assert_equal msg, "passed: env? TEST = array"
  end
  def test_env_fail_array
    result, msg = @test.execute "env[TEST]?=array", "", "", "", 0, {'TEST' => nil}
    assert !result
    assert_equal msg, "failed: env? TEST = array # was nil"
  end

  def test_env_success_nil
    result, msg = @test.execute "env[TEST]?=nil", "", "", "", 0, {'TEST' => nil }
    assert result
    assert_equal msg, "passed: env? TEST = nil"
  end
  def test_env_fail_nil
    result, msg = @test.execute "env[TEST]?=nil", "", "", "", 0, {'TEST' => {"1" => "test"}}
    assert !result
    assert_equal msg, "failed: env? TEST = nil # was array"
  end
end
