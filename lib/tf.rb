require 'rubygems'
require 'singleton'
require 'yaml'
require 'stringio'
require 'session'

lib_root = File.dirname( __FILE__ )

# include lib in path so plugins get found with Gem.find_files
$:.unshift "#{lib_root}"

class TF; end
# load tf/*.rb
Dir["#{lib_root}/tf/*.rb"].each{|lib| require lib }

class TF
  def initialize
    @ruby = File.join(RbConfig::CONFIG["bindir"],RbConfig::CONFIG["ruby_install_name"])
    @plugins = TF::Plugins.instance
    @failures = 0
  end

  def run_tests args
    @plugins.load(%w( all_test ))
    input_files, not_processed = @plugins.parse_args(args)
    if not_processed.size > 0
      $stderr.puts "No plugin recognized this option '#{not_processed*" "}'."
      exit 1
    end
    @plugins.load(%w( ErrorSummaryOutput )) if @plugins.output_plugins.empty?
    process(input_files)
    @failures == 0
  end

  def process input_files
    @plugins.output_plugins(:start_processing)
    input_files.each do |plugin,file|
      process_test( plugin.load(file) )
    end
    @plugins.output_plugins(:end_processing)
  end

  def env shell
    TF::Environment.parse_env(
      shell.execute(
        TF::Environment.show_env_command
      )[0].split(/\n/)
    )
  end

  def process_test test
    name, commands, execution_shell = test[:name], test[:commands], test[:shell]
    shell = Session::Sh.new(:prog => execution_shell)
    _env = env(shell)
    @plugins.output_plugins(:start_test, test, _env)
    commands.each do |line|
      command, tests = line[:cmd], line[:tests]
      @plugins.output_plugins(:start_command, line)
      _stdout  = StringIO.new
      _stderr  = StringIO.new
      _stdboth = StringIO.new
      shell.execute "#{command}" do |out, err|
        if out
          @plugins.output_plugins(:command_out, out)
          _stdout  << out
          _stdboth << out
        end
        if err
          @plugins.output_plugins(:command_err, err)
          _stderr  << err
          _stdboth << err
        end
      end
      _status = shell.status
      _env = env(shell)
      @plugins.output_plugins(:end_command, line, _status, _env)
      process_command_tests _stdout.string, _stderr.string, _stdboth.string, _status, _env, tests
    end
    @plugins.output_plugins(:end_test, test)
  rescue SystemExit, Interrupt
    shell.close!
    raise
  end

  def process_command_tests _stdout, _stderr, _stdboth, _status, env, tests
    tests.each do |test|
      plugin = @plugins.test_plugins.find{|_plugin| _plugin.matches? test }
      if plugin.nil?
        status, msg = false, "Could not find plugin for test '#{test}'."
      else
        status, msg = plugin.execute(test, _stdout, _stderr, _stdboth, _status, env)
      end
      @failures+=1 unless status
      @plugins.output_plugins(:test_processed, test, status, msg)
    end
  end

  class << self
  end
end
