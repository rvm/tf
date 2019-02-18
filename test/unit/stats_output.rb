require 'minitest/autorun'
require 'plugins/tf/stats_output'

class TestStatsOutput < MiniTest::Unit::TestCase
  def setup
    @test = TF::StatsOutput.new
  end

  # Build input data, will create command for every integer passed,
  # command will contain tests number equal to passed integer
  def build_input *arr
    arr.flatten!
    { :commands => arr.map{|count|
      { :tests => count==0 ? [] : (1..count).to_a }
    } }
  end

  def test_empty
    assert @test.status =~ /##### Processed commands 0 of 0/
  end

  def test_not_processed
    @test.start_test(build_input(0), {})

    assert_match( /##### Processed commands 0 of 1/, @test.status )
    refute_match( /(success|failure|skipped)/, @test.status )
  end

  def test_processed_success
    @test.start_test(build_input(1), {})
    @test.end_command( '', true, {} )
    @test.test_processed( {}, true, '' )

    assert_match( /##### Processed commands 1 of 1/, @test.status )
    assert_match( /success tests 1 of 1/, @test.status )
    refute_match( /(failure|skipped)/, @test.status )
  end

  def test_processed_failure
    @test.start_test(build_input(1), {})
    @test.end_command( '', true, {} )
    @test.test_processed( {}, false, '' )

    assert_match( /##### Processed commands 1 of 1/, @test.status )
    assert_match( /failure tests 1 of 1/, @test.status )
    refute_match( /(successskipped)/, @test.status )
  end

  def test_processed_skipped
    @test.start_test(build_input(1), {})
    @test.end_command( '', true, {} )

    assert_match( /##### Processed commands 1 of 1/, @test.status )
    assert_match( /skipped tests 1 of 1/, @test.status )
    refute_match( /(success|failure)/, @test.status )
  end

  def test_processed_all
    @test.start_test(build_input(1,2), {})
    2.times{ @test.end_command('',true,{}) }
    @test.test_processed( {}, true, '' )
    @test.test_processed( {}, false, '' )

    assert_match( /##### Processed commands 2 of 2/, @test.status )
    assert_match( /success tests 1 of 3/, @test.status )
    assert_match( /failure tests 1 of 3/, @test.status )
    assert_match( /skipped tests 1 of 3/, @test.status )
  end
end
