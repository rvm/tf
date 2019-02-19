class TF::OutputMatchTest
  MATCHER = /^match(\[(stdout|stderr)\])?([!]?=)[~]?\/(.*)\/$/

  def matches? test
    test =~ TF::OutputMatchTest::MATCHER
  end

  def execute test, _stdout, _stderr, _stdboth, _status, env
    test =~ TF::OutputMatchTest::MATCHER
    _, type, sign, value = $1, $2, $3, $4
    test_val, match_type =
      case type
      when "stdout" then [ _stdout, "[#{type}]" ]
      when "stderr" then [ _stderr, "[#{type}]" ]
      when nil      then [ _stdboth, "" ]
      else return [ false, "failed: match[#{type}] #{sign} /#{value}/ # unknown output type" ]
      end
    if ( sign == "=" ) ^ ( Regexp.new(value) =~ "#{test_val}" )
      [ false, "failed: match#{match_type} #{sign} /#{value}/" ]
    else
      [ true, "passed: match#{match_type} #{sign} /#{value}/" ]
    end
  end
end
