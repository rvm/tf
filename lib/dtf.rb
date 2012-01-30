require 'rubygems'
require 'singleton'
require 'yaml'
require 'session'

lib_root = File.dirname( __FILE__ )

# include lib in path so plugins get found with Gem.find_files
$: << "#{lib_root}"

class DTF; end
# load dtf/*.rb
Dir["#{lib_root}/dtf/*.rb"].each{|lib| require lib }

class DTF
  def initialize
    @plugins = DTF::Plugins.instance
  end

  def run_tests args
    #TODO: read wanted from project/user config
    wanted = %w( all ) #if wanted.empty?
    @plugins.load(wanted)
    process(args)
  end

  def process args
    input_data = Hash.new
    args.each{|arg|
      plugin = @plugins.input_plugins.find{|plugin| plugin.matches? arg }
      if plugin.nil?
        puts "Could not find plugin to read '#{arg}'."
      else
        name, commands = plugin.load(arg)
        process_test name, commands
      end
    }
  end

  def env shell
    Hash[ shell.execute("/usr/bin/printenv --null")[0].split("\0").map{|var| var.split('=', 2) } ]
  end

  def process_test name, commands
    shell = Session::Bash.new
    _env = env shell
    @plugins.output_plugins(:start_test, name, commands, _env)
    commands.each do |command, tests|
      @plugins.output_plugins(:start_command, command, tests)
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
      _env = env shell
      @plugins.output_plugins(:end_command, command, _status, _env)
      process_command_tests _stdout, _stderr, _stdboth, _status, _env, tests
    end
    @plugins.output_plugins(:end_test, name)
  end

  def process_command_tests _stdout, _stderr, _stdboth, _status, env, tests
    tests.each do |test|
      plugin = @plugins.test_plugins.find{|plugin| plugin.matches? test }
      if plugin.nil?
        puts "Could not find plugin for test '#{test}'."
      else
        status, msg = plugin.execute(test, _stdout, _stderr, _stdboth, _status, env)
        @plugins.output_plugins(:test_processed, test, status, msg)
      end
    end
  end

  class << self
  end
end
