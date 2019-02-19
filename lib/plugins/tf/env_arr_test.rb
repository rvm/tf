class TF::EnvArrTest
  MATCHER = {
    :all  => /^env\[([a-zA-Z_][a-zA-Z0-9_]*)\]\[\]([!]?=)[~]?\/(.*)\/$/,
    :one  => /^env\[([a-zA-Z_][a-zA-Z0-9_]*)\]\[(.+)\]([!]?=)[~]?\/(.*)\/$/,
    :size => /^env\[([a-zA-Z_][a-zA-Z0-9_]*)\]\[\]([!]?=)([[:digit:]]+)$/,
  }

  def matches? test
    TF::EnvArrTest::MATCHER.find{|k,v| test =~ v }
  end


  def execute test, _stdout, _stderr, _stdboth, _status, env
    type, matcher = TF::EnvArrTest::MATCHER.find{|k,v| test =~ v }
    $stderr.puts "EnvArrTest: #{type}." if ENV["TF_DEBUG"]
    send "execute_#{type}".to_sym, matcher, test, _stdout, _stderr, _stdboth, _status, env
  end

  def execute_one test, matcher, _stdout, _stderr, _stdboth, _status, env
    test =~ matcher
    variable, index, sign, value = $1.strip, $2, $3, $4
    var_val = env[ variable ]
    if var_val.is_a? Hash
      var_val = var_val[index]
    else
      return [ false, "failed: env #{variable}[#{index}] #{sign} /#{value}/ # not an array" ]
    end
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable}[#{index}] #{sign} /#{value}/ # was '#{var_val}'" ]
    else
      [ true, "passed: env #{variable}[#{index}] #{sign} /#{value}/" ]
    end
  end

  def execute_all test, matcher, _stdout, _stderr, _stdboth, _status, env
    test =~ matcher
    variable, sign, value = $1.strip, $2, $3, $4
    var_val = env[ variable ]
    if var_val.is_a? Hash
      var_val = var_val.sort_by{|k,v| k}.map{|k,v| v}.join(" ")
    else
      return [ false, "failed: env #{variable}[] #{sign} /#{value}/ # not an array" ]
    end
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable}[] #{sign} /#{value}/ # was '#{var_val}'" ]
    else
      [ true, "passed: env #{variable}[] #{sign} /#{value}/" ]
    end
  end

  def execute_size test, matcher, _stdout, _stderr, _stdboth, _status, env
    test =~ matcher
    variable, sign, value = $1.strip, $2, $3, $4
    var_val = env[ variable ]
    if var_val.is_a? Hash
      var_val = var_val.size
    else
      return [ false, "failed: env #{variable}[] #{sign} #{value} # not an array" ]
    end
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable}[] #{sign} #{value} # was #{var_val}" ]
    else
      [ true, "passed: env #{variable}[] #{sign} #{value}" ]
    end
  end
end
