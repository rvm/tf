class YATF::Plugins
  include Singleton

  def initialize
    detect
    @additional_plugins = []
    @input_plugins = []
    @output_plugins = []
    @test_plugins = []
  end

  def detect
    @plugins = Gem.find_files('plugins/yatf/*.rb')
  end
  
  def add plugin
    @additional_plugins << plugin
  end

  def delets plugin
    @additional_plugins.delete plugin
  end

  def list pattern=nil
    # collect to lists
    _list = @plugins + @additional_plugins
    # filter by pattern if given
    _list.select!{|item| item.match("_#{pattern}.rb$") } unless pattern.nil?
    # get path and class name
    _list.map!{|item| [ item, File.basename(item,'.rb').capitalize.gsub(/_(.)/){ $1.upcase } ] }
    _list
  end

  def load wanted
    [ :input, :test, :output ].each do |type|
      _list = list(type)
      if ! wanted.include?("all") && ! wanted.include?("all_#{type}")
        _list.select!{|item, klass| wanted.include?(klass) }
      end
      _list.each{|item, klass|
        require item
        eval("@#{type}_plugins << YATF::#{klass}.new")
      }
    end
  end

  def input_plugins
    @input_plugins
  end

  def output_plugins *args
    if args.nil?
      @output_plugins
    else
      @output_plugins.each{|plugin| plugin.send(*args) }
    end
  end

  def test_plugins
    @test_plugins
  end
end
