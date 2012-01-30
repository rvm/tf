require 'minitest/autorun'
require 'plugins/dtf/env_match_test'

class TestEnvMatchTest < MiniTest::Unit::TestCase
  def setup
    @test = DTF::EnvMatchTest.new
  end
  def test_matches
    assert @test.matches?("env[TEST]=/aa/")
    assert @test.matches?("env[OTHER]!=/^$/")
    assert @test.matches?("env[TEST]=~/Zb/")
    assert @test.matches?("env[TEST]!=~/^B.*C$/")
    assert ! @test.matches?("env[TEST]=a")
    assert ! @test.matches?("env[OTHER]!=")
    assert ! @test.matches?("aenv[TEST]!=//")
  end

  def test_env_success
    result, msg = @test.execute "env[TEST]=/test/", "", "", "", 0, {:TEST => "test"}
    assert result
    assert_equal msg, "passed: env TEST = /test/"
  end
  def test_env_failed
    result, msg = @test.execute "env[TEST]=/test/", "", "", "", 0, {:TEST => "other"}
    assert ! result
    assert_equal msg, "failed: env TEST = /test/ # was 'other'"
  end
  def test_env_not_success
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {:TEST => "other"}
    assert result
    assert_equal msg, "passed: env TEST != /test/"
  end
  def test_env_not_failed
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {:TEST => "test"}
    assert ! result
    assert_equal msg, "failed: env TEST != /test/ # was 'test'"
  end
end
