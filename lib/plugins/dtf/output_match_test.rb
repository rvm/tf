class DTF::OutputMatchTest
  MATCHER = /^match([!]?=)[~]?\/(.*)\//

  def matches? test
    test =~ DTF::OutputMatchTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ DTF::OutputMatchTest::MATCHER
    sign, value = $1, $2
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{_stdboth}" )
      [ false, "failed: match #{sign} /#{value}/" ]
    else
      [ true, "passed: match #{sign} /#{value}/" ]
    end
  end
end
