class DTF::TextOutput
  RED = `tput setaf 1`
  GREEN = `tput setaf 2`
  YELLOW = `tput setaf 3`
  BLUE = `tput setaf 4`
  RESET = `tput setaf 9`

  def initialize
  end

  def start_test name, commands, env
    commands ||= {}
    puts "#{BLUE}##### starting test #{name} with #{commands.keys.size} commands and #{commands.values.flatten.size} tests.#{RESET}"
  end

  def end_test name
    puts "#{BLUE}##### finished test #{name}.#{RESET}"
  end

  def start_command command, tests
    puts "#{YELLOW}$ #{command}#{RESET}"
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
    if status
      puts "#{GREEN}# #{msg}#{RESET}"
    else
      puts "#{RED}# #{msg}#{RESET}"
    end
  end
end
