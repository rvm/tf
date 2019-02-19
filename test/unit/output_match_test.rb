require 'minitest/autorun'
require 'plugins/tf/output_match_test'

class TestOutputMatchTest < Minitest::Test
  def setup
    @test = TF::OutputMatchTest.new
  end
  def test_matches
    assert @test.matches?("match=/aa/")
    assert @test.matches?("match!=/^$/")
    assert @test.matches?("match=~/Zb/")
    assert @test.matches?("match!=~/^B.*C$/")
    assert @test.matches?("match[stdout]=/aa/")
    assert @test.matches?("match[stdout]!=/^$/")
    assert @test.matches?("match[stderr]=~/Zb/")
    assert @test.matches?("match[stderr]!=~/^B.*C$/")
    assert ! @test.matches?("match[std]=/aa/")
    assert ! @test.matches?("match[out]!=/^$/")
    assert ! @test.matches?("match[err]=~/Zb/")
    assert ! @test.matches?("match[else]!=~/^B.*C$/")
    assert ! @test.matches?("match=a")
    assert ! @test.matches?("match!=")
    assert ! @test.matches?("amatch!=//")
  end

  def test_status_success
    result, msg = @test.execute "match=/test/", "", "", "test", 0, {}
    assert result
    assert_equal msg, "passed: match = /test/"
  end
  def test_status_failed
    result, msg = @test.execute "match=/test/", "", "", "other", 0, {}
    assert ! result
    assert_equal msg, "failed: match = /test/"
  end
  def test_status_not_success
    result, msg = @test.execute "match!=/test/", "", "", "other", 0, {}
    assert result
    assert_equal msg, "passed: match != /test/"
  end
  def test_status_not_failed
    result, msg = @test.execute "match!=/test/", "", "", "test", 0, {}
    assert ! result
    assert_equal msg, "failed: match != /test/"
  end

  def test_stdout_success
    result, msg = @test.execute "match[stdout]=/^out$/", "out", "err", "outerr", 0, {}
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "passed: match[stdout] = /^out$/"
  end
  def test_stdout_failed
    result, msg = @test.execute "match[stdout]=/^out$/", "outother", "err", "outerrother", 0, {}
    assert ! result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: match[stdout] = /^out$/"
  end
  def test_stdout_not_success
    result, msg = @test.execute "match[stdout]!=/^out$/", "outother", "err", "outerrother", 0, {}
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "passed: match[stdout] != /^out$/"
  end
  def test_stdout_not_failed
    result, msg = @test.execute "match[stdout]!=/^out$/", "out", "err", "outerr", 0, {}
    assert ! result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: match[stdout] != /^out$/"
  end

  def test_stderr_success
    result, msg = @test.execute "match[stderr]=/^err$/", "out", "err", "outerr", 0, {}
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "passed: match[stderr] = /^err$/"
  end
  def test_stderr_failed
    result, msg = @test.execute "match[stderr]=/^err$/", "out", "errother", "outerrother", 0, {}
    assert ! result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: match[stderr] = /^err$/"
  end
  def test_stderr_not_success
    result, msg = @test.execute "match[stderr]!=/^err$/", "out", "errother", "outerrother", 0, {}
    assert result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "passed: match[stderr] != /^err$/"
  end
  def test_stderr_not_failed
    result, msg = @test.execute "match[stderr]!=/^err$/", "out", "err", "outerr", 0, {}
    assert ! result, "wrong result(#{result}), the message was: #{msg}"
    assert_equal msg, "failed: match[stderr] != /^err$/"
  end

end
