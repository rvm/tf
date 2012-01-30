class DTF::EnvMatchTest
  MATCHER = /^env\[(.*)\]([!]?=)[~]?\/(.*)\//

  def matches? test
    test =~ DTF::EnvMatchTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ DTF::EnvMatchTest::MATCHER
    variable, sign, value = $1, $2, $3
    var_val = env[ variable.to_sym ]
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable} #{sign} /#{value}/ # was '#{var_val}'" ]
    else
      [ true, "passed: env #{variable} #{sign} /#{value}/" ]
    end
  end
end
