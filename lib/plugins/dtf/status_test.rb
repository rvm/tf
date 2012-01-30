class DTF::StatusTest
  MATCHER = /^status([!]?=)([[:digit:]]+)$/

  def matches? test
    test =~ DTF::StatusTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ DTF::StatusTest::MATCHER
    sign, value = $1, $2.to_i
    if ( sign == "=" ) ^ ( _status == value )
      [ false, "failed: status #{sign} #{value} # was #{_status}" ]
    else
      [ true, "passed: status #{sign} #{value}" ]
    end
  end
end
