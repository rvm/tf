require 'minitest/autorun'
require 'plugins/tf/env_match_test'

class TestEnvMatchTest < Minitest::Test
  def setup
    @test = TF::EnvMatchTest.new
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
    result, msg = @test.execute "env[TEST]=/test/", "", "", "", 0, {'TEST' => "test"}
    assert result
    assert_equal msg, "passed: env TEST = /test/"
  end
  def test_env_failed_str
    result, msg = @test.execute "env[TEST]=/test/", "", "", "", 0, {'TEST' => "other"}
    assert !result
    assert_equal msg, "failed: env TEST = /test/ # was 'other'"
  end
  def test_env_failed_arr
    result, msg = @test.execute "env[TEST]=/test/", "", "", "", 0, {'TEST' => {"1" => "other"} }
    assert !result
    assert_equal msg, "failed: env TEST = /test/ # not a string"
  end
  def test_env_not_success
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {'TEST' => "other"}
    assert result
    assert_equal msg, "passed: env TEST != /test/"
  end
  def test_env_not_failed_str
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {'TEST' => "test"}
    assert !result
    assert_equal msg, "failed: env TEST != /test/ # was 'test'"
  end
  def test_env_success_nil
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {'TEST' => nil}
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal "passed: env TEST != /test/", msg
  end
  def test_env_not_failed_arr
    result, msg = @test.execute "env[TEST]!=/test/", "", "", "", 0, {'TEST' => {"1" => "other"} }
    assert ! result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal "failed: env TEST != /test/ # not a string", msg
  end
end
