require 'minitest/autorun'
require 'plugins/tf/env_arr_test'

class TestEnvArrTest < Minitest::Test
  def setup
    @test = TF::EnvArrTest.new
  end
  def test_matches
    assert @test.matches?("env[TEST][]=3")
    assert @test.matches?("env[TEST][]!=3")
    assert ! @test.matches?("env[OTHER]=/3/")
    assert ! @test.matches?("env[OTHER]!=/3/")
    assert @test.matches?("env[TEST][]=/dsf/")
    assert @test.matches?("env[TEST][]!=/dsf/")
    assert ! @test.matches?("env[OTHER][]=a/dsf/")
    assert ! @test.matches?("env[OTHER][]!=b/dsf/")
    assert @test.matches?("env[TEST][1]=/dsf/")
    assert @test.matches?("env[TEST][1]!=/dsf/")
    assert ! @test.matches?("env[OTHER][1]=a/dsf/")
    assert ! @test.matches?("env[OTHER][1]!=b/dsf/")
  end

  def test_env_arr_size_success
    result, msg = @test.execute "env[TEST][]=2", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert result
    assert_equal msg, "passed: env TEST[] = 2"
  end
  def test_env_arr_size_failure
    result, msg = @test.execute "env[TEST][]=3", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert !result
    assert_equal msg, "failed: env TEST[] = 3 # was 2"
  end
  def test_env_arr_size_failure_type
    result, msg = @test.execute "env[TEST][]=4", "", "", "", 0, {'TEST' => nil }
    assert !result
    assert_equal msg, "failed: env TEST[] = 4 # not an array"
  end

  def test_env_arr_one_success
    result, msg = @test.execute "env[TEST][1]=/a/", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert result
    assert_equal msg, "passed: env TEST[1] = /a/"
  end
  def test_env_arr_one_failure
    result, msg = @test.execute "env[TEST][1]=/lol/", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert !result
    assert_equal msg, "failed: env TEST[1] = /lol/ # was 'a'"
  end
  def test_env_arr_one_failure_type
    result, msg = @test.execute "env[TEST][1]=/lol/", "", "", "", 0, {'TEST' => nil }
    assert !result
    assert_equal msg, "failed: env TEST[1] = /lol/ # not an array"
  end

  def test_env_arr_all_success
    result, msg = @test.execute "env[TEST][]=/a b/", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "passed: env TEST[] = /a b/"
  end
  def test_env_arr_all_failure
    result, msg = @test.execute "env[TEST][]=/lol/", "", "", "", 0, {'TEST' => {"1"=>"a", "2"=>"b"} }
    assert !result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: env TEST[] = /lol/ # was 'a b'"
  end
  def test_env_arr_all_failure_type
    result, msg = @test.execute "env[TEST][]=/lol/", "", "", "", 0, {'TEST' => nil }
    assert !result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: env TEST[] = /lol/ # not an array"
  end
end
