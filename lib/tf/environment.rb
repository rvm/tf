## https://github.com/mpapis/mpapis_test/blob/master/variables_list.sh

## Examples BASH:
#~ USER=vagrant
#~ _=
#~ array2=([0]="four" [1]="five" [2]="six" [10]="ten")
#~ variable1='play'\''me'
#~ variable2=$'play\n with\n me\n now'

## Examples ZSH:
#~ FIGNORE=''
#~ USER=vagrant
#~ array2=(four five six '' '' '' '' '' '' ten)
#~ variable1='play'\''me'
#~ variable2='play
#~  with
#~  me
#~  now'
require 'shellwords'

class TF::Environment
  HANDLER=<<EOF
__tf_show_env_tool()
{
typeset v x y

for v in $( set | grep -Eao "^[^=]*=[\('\$]?" )
do
  x="${v##*=}"
  if [[ -n "$x" ]]
  then
    y="${x/\(/)}"
    y="${y/\$/\'}"
    v="${v%$x}"
    v="${v//\*/\*}"
    set | sed -n '/^'"$v"'/{: rep ; /'"$y$"'/!{N; b rep; }; p;}'
  else
    set | grep -a "^$v"
  fi
done
}
EOF
  class << self
    def define_handler
      TF::Environment::HANDLER
    end
    def handler_command
      '__tf_show_env_tool'
    end
    def parse_env output
      env = []
      holder=nil
      terminator=nil
      output.each do |line|
        if holder.nil? && line =~ /^[^=]*=([\('$]?)/
          holder = line
          until $1.nil?
            terminator = $1.sub(/$/,"'").sub(/\(/,")")
            terminator << '$'
            terminator = Regexp.new(terminator)
          end
        else
          holder += line
        end
        if terminator && line =~ terminator
          terminator=nil
        end
        if holder && terminator.nil?
          env << parse_var(holder)
          holder=nil
        end
      end
      Hash[ env ]
    end
    def parse_var definition
      definition =~ /\A([^=]*)=([$]?[\(']?)(.*?)([\)']?)\z/m
      name  = $1
      type1 = $2
      value = $3
      type2 = $4
      case type2
      when ')'
        parse_array( name, value.shellsplit.map{|v|v.gsub(/'\''/,'\'')} )
      else
        [ name, value.gsub(/'\''/,'\'') ]
      end
    end
    def parse_array name, value
      if value[0] && value[0][0] == '['
        value = value.map do |string|
          string =~ /\[([^\]]+)\]=(.*)/m
          [ $1, $2 ]
        end
      else
        value = value.to_enum.with_index.map{|v,i|[(i+1).to_s,v]}.to_a
        # TODO: zsh -c 'typeset -A arr; arr[ala]=1; arr[kot]=2; set | grep -a ^arr=' => arr=(ala 1 kot 2 ) - space on the end
      end
      [ name, Hash[ value ] ]
    end
  end
end
