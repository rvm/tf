require 'rubygems'
require 'singleton'
require 'yaml'

lib_root = File.dirname( __FILE__ )

# include lib in path so plugins get found with Gem.find_files
$: << "#{lib_root}"

class YATF; end
# load yatf/*.rb
Dir["#{lib_root}/yatf/*.rb"].each{|lib| require lib }

class YATF
  def initialize
    @plugins = YATF::Plugins.instance
  end

  def run_tests args
    wanted = %w( CommentTestInput TextOutput all_test )
    @plugins.load(wanted)
  end

  class << self
  end
end
