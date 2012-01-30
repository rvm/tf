require 'minitest/autorun'
require 'plugins/dtf/output_match_test'

class TestOutputMatchTest < MiniTest::Unit::TestCase
  def setup
    @test = DTF::OutputMatchTest.new
  end
  def test_matches
    assert @test.matches?("match=/aa/")
    assert @test.matches?("match!=/^$/")
    assert @test.matches?("match=~/Zb/")
    assert @test.matches?("match!=~/^B.*C$/")
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
end
