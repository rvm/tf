class DTF::Plugins
  include Singleton

  def initialize
    detect
    @additional_plugins = []
    @input_plugins = []
    @output_plugins = []
    @test_plugins = []
  end

  def detect
    @plugins = Gem.find_files('plugins/dtf/*.rb')
  end
  
  def add plugin
    @additional_plugins << plugin
  end

  def delets plugin
    @additional_plugins.delete plugin
  end

  def file_to_class item
    File.basename(item,'.rb').capitalize.gsub(/_(.)/){ $1.upcase }
  end

  def list pattern=nil
    # collect to lists
    _list = @plugins + @additional_plugins
    # filter by pattern if given
    _list.select!{|item| item.match("_#{pattern}.rb$") } unless pattern.nil?
    # get path and class name
    _list.map!{|item| [ item, file_to_class(item), pattern ] }
    # TODO: limit plugin versions (highest || use bundler)
    _list.each{|item, klass, type| require item }
    _list
  end

  def load wanted
    [ :input, :test, :output ].each do |type|
      _list = list(type)
      if ! wanted.include?("all") && ! wanted.include?("all_#{type}")
        _list.select!{|item, klass, _type| wanted.include?(klass) }
      end
      _list.each{|item, klass, _type|
        klass = DTF.const_get(klass)
        instance_variable_get("@#{type}_plugins".to_sym) << klass.new
      }
    end
  end

  def match_arg_klass arg, klass, type
    klass = DTF.const_get(klass)
    return nil unless klass.respond_to? :argument_matches?
    matches = klass.argument_matches? arg
    return nil if matches.nil?
    matches.each do |match|
      case match
      when :load
        instance_variable_get("@#{type}_plugins".to_sym) << klass.new
      when :input
        @input_files << [klass.new, arg]
      else
        return nil
      end
    end
    return matches
  rescue NameError
    return nil
  end

  def parse_args args
    @input_files, not_processed = [], []
    available_plugins = [ :input, :test, :output ].map{ |type| list(type) }.flatten(1)
    args.each do |arg|
      matched = available_plugins.map do |item, klass, type|
        match_arg_klass arg, klass, type
      end.flatten.reject(&:nil?)
      if matched.empty?
        not_processed << arg
      end
    end
    [ @input_files, not_processed ]
  end

  def input_plugins
    @input_plugins
  end

  def output_plugins *args
    if args.empty?
      @output_plugins
    else
      @output_plugins.each{|plugin| plugin.send(*args) }
    end
  end

  def test_plugins
    @test_plugins
  end
end
