class DTF::ErrorSummaryOutput
  RED = `tput setaf 1`
  GREEN = `tput setaf 2`
  YELLOW = `tput setaf 3`
  BLUE = `tput setaf 4`
  RESET = `tput setaf 9`

  def initialize
    @counts={}
    @counts[:commands] = 0
    @counts[:tests] = 0
    @counts[:commands_started] = 0
    @counts[:commands_finished] = 0
    @counts[:tests_success] = 0
    @counts[:tests_failure] = 0
    @counter_id = 0
    @summary = {}
  end

  def start_processing
  end

  def status
    text = "#{BLUE}##### Processed commands #{@counts[:commands_finished]} of #{@counts[:commands]}"
    if @counts[:tests_success] > 0
      text += ", #{GREEN}success tests #{@counts[:tests_success]} of #{@counts[:tests]}"
    end
    if @counts[:tests_failure] > 0
      text += ", #{RED}failure tests #{@counts[:tests_failure]} of #{@counts[:tests]}"
    end
    skipped = @counts[:tests] - @counts[:tests_success] - @counts[:tests_failure]
    if skipped > 0
      text += ", #{YELLOW}skipped tests #{skipped} of #{@counts[:tests]}"
    end
    text += ".#{RESET}"
    text
  end

  def summary
    @summary.sort{|a,b| ak,av=a ; bk,bv=b ; ak <=> ab }.each{|k,v|
      puts "#{YELLOW}$ #{v[:cmd]}#{RESET}"
      v[:failed_tests].each{|t| puts "#{RED}# #{t}#{RESET}" }
    }
    text = ""
    text
  end

  def end_processing
    printf "\n"
    puts status
    puts summary
  end

  def start_test test, env
    @counts[:commands] += test[:commands].size
    tests_counts = test[:commands].map{|line| line[:tests].nil? ? 0 : line[:tests].size }
    @counts[:tests] += tests_counts.empty? ? 0 : tests_counts.inject(&:+)
  end

  def end_test test
  end

  def start_command line
    @counts[:commands_started] += 1
    @current_line = line.merge(:counter_id => @counts[:commands_started])
  end

  def end_command line, status, env
    @counts[:commands_finished] += 1
  end

  def command_out out
  end

  def command_err err
  end

  def test_processed test, status, msg
    printf status ? "." : "F"
    if status
      @counts[:tests_success] += 1
    else
      @counts[:tests_failure] += 1
      @summary[@current_line[:counter_id]] ||= @current_line.merge(:failed_tests=>[])
      @summary[@current_line[:counter_id]][:failed_tests] << msg
    end
  end
end
