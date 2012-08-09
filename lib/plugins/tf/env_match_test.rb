class TF::EnvMatchTest
  MATCHER = /^env\[([a-zA-Z_][a-zA-Z0-9_]*)\]([!]?=)[~]?\/(.*)\/$/

  def matches? test
    test =~ TF::EnvMatchTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ TF::EnvMatchTest::MATCHER
    variable, sign, value = $1.strip, $2, $3
    var_val = env[ variable ]
    if  !(var_val.nil?) && !(var_val.is_a?(String))
      $stderr.puts "Not a string: #{var_val}, type:#{var_val.class}." if ENV["TF_DEBUG"]
      return [ false, "failed: env #{variable} #{sign} /#{value}/ # not a string" ]
    end
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable} #{sign} /#{value}/ # was '#{var_val}'" ]
    else
      [ true, "passed: env #{variable} #{sign} /#{value}/" ]
    end
  end
end
