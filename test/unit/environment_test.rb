require 'minitest/autorun'

class TestEnvironment < Minitest::Test
  def setup
    @test = TF::Environment
  end

  def test_parse_array_bash
    result = @test.parse_array :array_bash, '[0]="four" [1]="five" [2]="six" [10]="ten"'.shellsplit
    bash_expected=[:array_bash, {'0'=>'four','1'=>'five','2'=>'six','10'=>'ten'} ]
    assert_equal bash_expected, result
  end
  def test_parse_array_zsh
    result = @test.parse_array :array_zsh, "four five six '' '' '' '' '' '' ten".shellsplit
    zsh_expected=[:array_zsh, {'1'=>'four','2'=>'five','3'=>'six','4'=>'','5'=>'','6'=>'','7'=>'','8'=>'','9'=>'','10'=>'ten'} ]
    assert_equal zsh_expected, result
  end

  def test_parse_var
    {
      "_="                     => ["_",       '' ],
      "FIGNORE=''"             => ["FIGNORE", '' ],

      "USER=vagrant"           => ["USER",      "vagrant"],
      "variable1='play'\''me'" => ["variable1", "play'me"],

      'variable2=$\'play\n with\n me\n now\'' => ["variable2", 'play\n with\n me\n now'],
      "variable2=$'play\n with\n me\n now'"   => ["variable2", "play\n with\n me\n now"],

      'array1=([0]="four" [1]="five" [2]="six" [10]="ten")' => ["array1", {'0'=>'four','1'=>'five','2'=>'six','10'=>'ten'} ],
      "array2=(four five six '' '' '' '' '' '' ten)"        => ["array2", {'1'=>'four','2'=>'five','3'=>'six','4'=>'','5'=>'','6'=>'','7'=>'','8'=>'','9'=>'','10'=>'ten'} ]

    }.each do |example, result|
      assert_equal(result, @test.parse_var( example ) )
    end
  end

  def test_show_env_command_bash_session
    shell = Session::Sh.new(:prog => 'bash')
    result = shell.execute("x=3;\n#{@test.show_env_command}")
    result = result[0].split(/\n/)
    result = @test.parse_env( result )
    assert_equal "3", result["x"]
  end

  def test_show_env_command_zsh_session
    shell = Session::Sh.new(:prog => 'zsh')
    result = shell.execute("x=3;\n#{@test.show_env_command}")
    result = result[0].split(/\n/)
    result = @test.parse_env( result )
    assert_equal "3", result["x"]
  end

  def test_show_env_command_zsh_popen
    result = IO.popen("x=3;\n#{@test.show_env_command}") {|io|io.readlines}
    result = @test.parse_env( result )
    assert_equal "3", result["x"]
  end
end
