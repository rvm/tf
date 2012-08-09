class TF::EnvTypeTest
  MATCHER = /^env\[([a-zA-Z_][a-zA-Z0-9_]*)\]\?([!]?=)(array|string|nil)/

  def matches? test
    test =~ TF::EnvTypeTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ TF::EnvTypeTest::MATCHER
    variable, sign, type = $1.strip, $2, $3
    var_type = variable_type( env[ variable ] )
    if ( sign == "=" ) ^ ( var_type == type )
      [ false, "failed: env? #{variable} #{sign} #{type} # was #{var_type}" ]
    else
      [ true, "passed: env? #{variable} #{sign} #{type}" ]
    end
  end

  def variable_type value
    value.nil? ? 'nil' :
      value.is_a?(Hash) ? 'array' : 'string'
  end
end
