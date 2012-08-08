class TF::EnvMatchTest
  MATCHER = /^env\[(.*)\]([!]?=)[~]?\/(.*)\//

  def matches? test
    test =~ TF::EnvMatchTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ TF::EnvMatchTest::MATCHER
    variable, sign, value = $1.strip, $2, $3
    var_val = env[ variable ]
    var_val = "not a string" unless var_val.is_a? String
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{var_val}" )
      [ false, "failed: env #{variable} #{sign} /#{value}/ # was '#{var_val}'" ]
    else
      [ true, "passed: env #{variable} #{sign} /#{value}/" ]
    end
  end
end
