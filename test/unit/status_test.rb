require 'minitest/autorun'
require 'plugins/tf/status_test'

class TestStatusTest < Minitest::Test
  def setup
    @test = TF::StatusTest.new
  end
  def test_matches
    assert @test.matches?("status=0")
    assert @test.matches?("status!=0")
    assert @test.matches?("status=1")
    assert @test.matches?("status!=1")
    assert ! @test.matches?("status=a")
    assert ! @test.matches?("status=")
    assert ! @test.matches?("astatus!=1")
  end

  def test_status_success
    result, msg = @test.execute "status=0", "", "", "", 0, {}
    assert result
    assert_equal msg, "passed: status = 0"
  end
  def test_status_failed
    result, msg = @test.execute "status=0", "", "", "", 1, {}
    assert ! result
    assert_equal msg, "failed: status = 0 # was 1"
  end
  def test_status_not_success
    result, msg = @test.execute "status!=0", "", "", "", 1, {}
    assert result
    assert_equal msg, "passed: status != 0"
  end
  def test_status_not_failed
    result, msg = @test.execute "status!=0", "", "", "", 0, {}
    assert ! result
    assert_equal msg, "failed: status != 0 # was 0"
  end
end
