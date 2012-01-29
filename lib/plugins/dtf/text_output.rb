class DTF::TextOutput
  def initialize
  end

  def start_test name, commands, env
    commands ||= {}
    puts "##### starting test #{name} with #{commands.keys.size} commands and #{commands.values.flatten.size} tests."
  end

  def end_test name
    puts "##### finished test #{name}."
  end

  def start_command command, tests
    puts "$ #{command}"
  end

  def end_command command, status, env
    #puts ": $?=#{status}"
  end

  def command_out out
    puts out
  end

  def command_err err
    puts err
  end

  def test_processed test, status, msg
    puts "# #{msg}"
  end
end
