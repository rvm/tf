class TF::TextOutput
  RED = `tput setaf 1`
  GREEN = `tput setaf 2`
  YELLOW = `tput setaf 3`
  BLUE = `tput setaf 4`
  RESET = `tput setaf 9`

  def self.argument_matches? argument
    [:load] if argument == "--text"
  end

  def initialize
  end

  def start_processing
  end

  def end_processing
  end

  def start_test test, env
    puts "#{BLUE}##### starting test #{test[:name]}.#{RESET}"
  end

  def end_test test
    #puts "#{BLUE}##### finished test #{test[:name]}.#{RESET}"
  end

  def start_command line
    puts "#{YELLOW}$ #{line[:cmd]}#{RESET}"
  end

  def end_command line, status, env
    #puts ": $?=#{status}"
  end

  def command_out out
    puts out
  end

  def command_err err
    $stderr.puts err
  end

  def test_processed test, status, msg
    if status
      puts "#{GREEN}# #{msg}#{RESET}"
    else
      puts "#{RED}# #{msg}#{RESET}"
    end
  end
end
