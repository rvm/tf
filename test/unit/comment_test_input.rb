require 'minitest/autorun'
require 'plugins/tf/comment_test_input'

class TestCommentTestInput < Minitest::Test
  def setup
    @test = TF::CommentTestInput
    @file1 = Tempfile.new(['','_comment_test.sh'])
    @file2 = Tempfile.new(['','_wrong_test.sh'])
  end

  def teardown
    @file1.unlink
    @file2.unlink
  end

  def file_open file, &block
    file.open
    block.call
  ensure
    file.close
  end

  def test_matches
    assert @test.argument_matches?(@file1.path), "'#{@file1.path}' did not matched"
    assert !@test.argument_matches?(@file2.path), "'#{@file2.path}' matched but should not"
    assert !@test.argument_matches?("/path/to/file.rb")
    assert !@test.argument_matches?("/path/to/file_comment_test.rb")
    assert !@test.argument_matches?("anything")
  end

  def test_reading_two_different_lines
    file_open @file1 do
      @file1.write "true # status=0\n"
      @file1.write "false # status!=0; match=/^$/\n"
    end
    data = @test.new.load @file1.path
    assert !data[:commands].empty?, "Commands missing '#{data}'."
    assert_equal data[:commands].size, 2, "Wrong number of commands '#{data[:commands]}'."
    assert !data[:commands][0][:cmd].empty?, "Command missing '#{data[:commands][0]}'."
    assert !data[:commands][0][:tests].empty?, "Tests missing '#{data[:commands][0]}'."
    assert_equal data[:commands].map{|line| line[:tests].size }.inject(&:+), 3, "Wrong number of tests '#{data[:commands]}'."
  end

  def test_reading_two_same_commands
    file_open @file1 do
      @file1.write "true # status=0\n"
      @file1.write "true # status!=0; match=/^$/\n"
    end
    data = @test.new.load @file1.path
    assert_equal data[:commands].size, 2, "Wrong number of commands '#{data[:commands]}'."
    assert_equal data[:commands].map{|line| line[:tests].size }.inject(&:+), 3, "Wrong number of tests '#{data[:commands]}'."
  end

  def test_reading_empty_lines
    file_open @file1 do
      @file1.write "true # status=0\n"
      @file1.write "\n"
      @file1.write "true # status!=0; match=/^$/\n"
    end
    data = @test.new.load @file1.path
    assert_equal data[:commands].size, 2, "Wrong number of commands '#{data[:commands]}'."
    assert_equal data[:commands].map{|line| line[:tests].size }.inject(&:+), 3, "Wrong number of tests '#{data[:commands]}'."
  end

  def test_reading_user_comments
    file_open @file1 do
      @file1.write "##true # status=0\n"
      @file1.write "true # status!=0; match=/^$/ ## nothing to add\n"
    end
    data = @test.new.load @file1.path
    assert_equal data[:commands].size, 1, "Wrong number of commands '#{data[:commands]}'."
    assert_equal data[:commands].map{|line| line[:tests].size }.inject(&:+), 2, "Wrong number of tests '#{data[:commands]}'."
  end

  def test_reading_multiline_tests
    file_open @file1 do
      @file1.write "true"
      @file1.write "# status=0\n"
      @file1.write "true\n"
      @file1.write "# status!=0\n"
      @file1.write "# match=/^$/\n"
    end
    data = @test.new.load @file1.path
    assert_equal data[:commands].size, 2, "Wrong number of commands '#{data[:commands]}'."
    assert_equal data[:commands].map{|line| line[:tests].size }.inject(&:+), 3, "Wrong number of tests '#{data[:commands]}'."
  end
end
