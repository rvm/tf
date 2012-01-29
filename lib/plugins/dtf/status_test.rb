class DTF::StatusTest
  def initialize
  end

  def matches? test
    test =~ /^status([!]?=)(.*)/
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ /^status([!]?=)(.*)/
    sign, value = $1, $2.to_i
    if ( sign == "=" ) ^ ( _status == value )
      [ false, "failed: status #{sign} #{value} # was #{_status}" ]
    else
      [ true, "passed: status #{sign} #{value}" ]
    end
  end
end
